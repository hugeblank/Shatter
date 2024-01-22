local cce = require("cc.expect")
local expect, range = cce.expect, cce.range

---write text in grid fashion and add to table
---@param screen Screen
---@param state State
---@param x integer
---@param y integer
---@param char string
---@param fgcolor integer
---@param bgcolor integer
local function draw(screen, state, x, y, char, fgcolor, bgcolor)
    x, y = math.floor(x), math.floor(y)
    if x > 0 and y > 0 and x <= state.tx and y <= state.ty then
        local px, py = (x - 1) * state.ox, (y - 1) * state.oy
        local pixel = screen[x][y]
        if not pixel.bg then
            pixel.bg = state.can.addRectangle(px, py, state.ox, state.oy, bgcolor)
        else
            if pixel.bg.getColor() ~= bgcolor then
                pixel.bg.setColor(bgcolor)
            end
        end
        local nonwhite = #char > 0 and not char:match("%s")
        if not pixel.fg and nonwhite then -- Only render if there's a non-whitespace character present.
            pixel.fg = state.can.addText({ px, py + 1 }, char, fgcolor, state.ox / state.sx)
        elseif pixel.fg then
            if not nonwhite then
                pixel.fg.remove()
                pixel.fg = nil
                return
            end
            if pixel.fg.getColor() ~= fgcolor then
                pixel.fg.setColor(fgcolor)
            end
            if pixel.fg.getText() ~= char then
                pixel.fg.setText(char)
            end
        end
    end
end

---get the data of a particular pixel
---@param screen Screen
---@param state State
---@param i integer
---@param j integer
---@return string char
---@return integer fgc
---@return integer bgc
local function getData(screen, state, i, j)
    local pixel = screen[i][j]
    if pixel then
        if pixel.fg then
            return pixel.fg.getText(), pixel.fg.getColor(), pixel.bg.getColor()
        else
            return "", state.fg, pixel.bg.getColor()
        end
    end
    return "", state.fg, state.bg
end

--- Create a screen table
---@param can ObjectGroup2D
---@param state State
---@return Screen
---@return TextObject
local function makeScreen(can, state)
    local screen = {}
    local x, y = can.getSize()
    for i = 1, math.floor(x / state.ox) do
        screen[i] = {}
        for j = 1, math.floor(y / state.oy) do
            screen[i][j] = {}
            draw(screen, state, i, j, "", state.fg, state.bg)
        end
    end
    csr = can.addText({ state.cx * state.ox, (state.cy * state.oy) + 1 }, "", state.fg+state.fga, state.ox / state.sx)
    return screen, csr
end


---Create a default State object
---@param can ObjectGroup2D
---@return State
local function defaultState(can)
    local colormap = { ---@type colormap
        [colors.white] = 0xf0f0f000,
        [colors.orange] = 0xf2b23300,
        [colors.magenta] = 0xe57fd800,
        [colors.lightBlue] = 0x99b2f200,
        [colors.yellow] = 0xdede6c00,
        [colors.lime] = 0x7fcc1900,
        [colors.pink] = 0xf2b2cc00,
        [colors.gray] = 0x4c4c4c00,
        [colors.lightGray] = 0x99999900,
        [colors.cyan] = 0x4c99b200,
        [colors.purple] = 0xb266e500,
        [colors.blue] = 0x3366cc00,
        [colors.brown] = 0x7f664c00,
        [colors.green] = 0x57a64e00,
        [colors.red] = 0xcc4c4c00,
        [colors.black] = 0x19191900
    }

    local state = {
        -- canvas and color mappings
        can = can,
        colormap = colormap,
        -- term bg and fg colors and alpha values
        bg = colormap[colors.black],
        fg = colormap[colors.white],
        bgbn = colors.black,
        fgbn = colors.white,
        fga = 255,
        bga = 255,
        -- default term scale
        sx = 6,
        sy = 9,
        -- cursor pos and blink
        cx = 1,
        cy = 1,
        cb = true,
    }
    -- current term scale
    state.ox, state.oy = state.sx, state.sy

    -- term size
    local tx, ty = can.getSize()
    state.tx, state.ty = math.floor(tx / state.ox), math.floor(ty / state.oy)

    return state
end

--- Creates a shattered terminal
---@param can ObjectGroup2D
---@return ShatterTerm, function
function addTerm(can)
    assert(can.addRectangle and can.addText and can.getSize, "Shatter expects a canvas or group with addRectangle & addText")

    -- internal screen and state objects
    local state = defaultState(can)
    local screen, csr = makeScreen(can, state)

    -- Table of functions to be outputted
    local out = {}

    out.write = function(str)
        str = tostring(str)
        for i = 1, #str do
            draw(screen, state, state.cx+i-1, state.cy, str:sub(i, i), state.fg+state.fga, state.bg+state.bga)
        end
        state.cx = state.cx+#str
    end

    out.blit = function(str, tfg, tbg)
        expect(1, str, "string")
        expect(2, tfg, "string")
        expect(3, tbg, "string")
        for i = 1, #str do
            nfg = state.colormap[2 ^ (tonumber(tfg:sub(i, i), 16) or 0)]
            nbg = state.colormap[2 ^ (tonumber(tbg:sub(i, i), 16) or 0)]
            draw(screen, state, state.cx+i-1, state.cy, str:sub(i,i), nfg+state.fga, nbg+state.bga)
        end
        state.cx = state.cx+#str
    end

    out.clear = function()
        for i = 1, state.tx do
            for j = 1, state.ty do
                draw(screen, state, i, j, "", state.fg+state.fga, state.bg+state.bga)
            end
        end
    end

    out.clearLine = function(y)
        y = y or state.cy
        if y > 0 and y <= state.ty then
            for i = 1, state.tx do
                draw(screen, state, i, y, "", state.fg+state.fga, state.bg+state.bga)
            end
        end
    end

    out.getCursorPos = function()
        return state.cx, state.cy
    end

    out.setCursorPos = function(x, y)
        expect(1, x, "number")
        expect(2, y, "number")
        csr.setPosition((x-1)*state.ox, ((y-1)*state.oy)+1)
        state.cx, state.cy = x, y
    end

    out.setCursorBlink = function(b)
        expect(1, b, "boolean")
        if b then
            os.queueEvent("shatter_cursor_blink")
        end
        state.cb = b
    end

    out.isColor = function()
        return true, 0xffffff
    end

    out.getSize = function()
        return state.tx, state.ty
    end

    out.scroll = function(amount)
        expect(1, amount, "number")
        for i = 1, state.tx do
            local j = i-amount
            if i > 0 and i <= state.ty and j > 0 and j <= state.ty then
                screen[j] = screen[i]
                --screen[i] = {}
            elseif not (i > 0 and i <= state.ty) then
                out.clearLine(i)
            end
        end
    end

    out.setTextColor = function(col)
        expect(1, col, "number")
        local cl = state.colormap[col]
        if cl then
            state.fg = cl
            state.fgbn = col
            csr.setColor(state.fg+state.fga)
        else
            error("invalid color (got "..tostring(col)..")", 2)
        end
    end

    out.setBackgroundColor = function(col)
        expect(1, col, "number")
        local cl = state.colormap[col]
        if cl then
            state.bg = cl
            state.bgbn = col
        else
            error("invalid color (got "..tostring(col)..")", 2)
        end
    end

    -- Text & BG Alpha innovated by MC:Ale32bit
    out.setTextAlpha = function(val)
        expect(1, val, "number")
        val = math.max(0, math.min(1, val))
        state.fga = math.floor(val*255)
        csr.setAlpha(state.fga)
    end

    out.setBackgroundAlpha = function(val)
        expect(1, val, "number")
        val = math.max(0, math.min(1, val))
        state.bga = math.floor(val*255)
    end

    --- Set the text to a custom hexadecimal value.
    -- Overrides the default alpha value as well, if setTextAlpha has been used.
    -- Appears as colors.black to getTextColor, use getTextHex instead.
    out.setTextHex = function(hex)
        expect(1, hex, "number")
        state.fg = hex
        state.fgbn = colors.black
        csr.setColor(state.fg)
    end

    --- Set the background to a custom hexadecimal value. 
    -- Overrides the default alpha value as well, if setBackgroundAlpha has been used.
    -- Appears as colors.black to getBackgroundColor, use getBackgroundHex instead.
    out.setBackgroundHex = function(hex)
        expect(1, hex, "number")
        state.bg = hex
        state.bgbn = colors.black
    end

    out.getTextColor = function()
        return state.fgbn
    end

    out.getBackgroundColor = function()
        return state.bgbn
    end

    out.getTextAlpha = function()
        return state.fga/255
    end

    out.getBackgroundAlpha = function()
        return state.bga/255
    end

    out.getTextHex = function()
        return state.fg
    end

    out.getBackgroundHex = function()
        return state.bg
    end

    out.getPaletteColor = function(col)
        expect(1, col, "number")
        local cl = state.colormap[col]
        if not cl then
            error("invalid color (got " .. tostring(col) .. ")", 2)
        end
        -- Technically also gets a value, but it thrown out due to what this is needed for
        -- Credit to MC:valithor2 for this algorithm
        local vals = {}
        for i = 1, 4 do
            vals[i] = cl % 256
            cl = (cl - vals[i]) / 256
        end
        return vals[4] / 255, vals[3] / 255, vals[2] / 255
    end

    out.setPaletteColor = function(cnum, r, g, b)
        expect(1, cnum, "number")
        expect(2, r, "number")
        expect(3, g, "number", "nil")
        expect(4, b, "number", "nil")
        local colormap = state.colormap
        local oc = colormap[cnum]
        if not oc then
            error("invalid color (got "..tostring(cnum)..")", 2)
        end
        if g then
            if r > 1 then r = 1 elseif r < 0 then r = 0 end
            if g > 1 then g = 1 elseif g < 0 then g = 0 end
            if b > 1 then b = 1 elseif b < 0 then b = 0 end
            colormap[cnum] = ((r * 255) * (16^6)) + ((g * 255) * (16^4)) + ((b * 255) * (16^2))
        else
            colormap[cnum] = bit32.lshift(r, 8)
        end
        if state.fgbn == cnum then
            csr.setColor(colormap[cnum] + state.fga)
        end
        -- refreshes terminal when palette values are manipulated
        for i = 1, #screen do
            for j = 1, #screen[i] do
                local txt, fgc, bgc = getData(screen, state, i, j)
                local changed = false
                if bgc == oc then
                    bgc = colormap[cnum]
                    changed = true
                end
                if fgc == oc then
                    fgc = colormap[cnum]
                    changed = true
                end
                if changed then
                    draw(screen, state, i, j, txt, fgc, bgc)
                end
            end
        end
    end

    out.setScale = function(scale)
        expect(1, scale, "number")
        range(scale, 0.5, 10)
        state.ox, state.oy = math.ceil(scale*state.sx), math.ceil(scale*state.sy)
        local tx, ty = can.getSize()
        state.tx, state.ty = math.floor(tx/state.ox), math.floor(ty/state.oy)
        local oldscr = screen -- replicate the screen
        screen = makeScreen(can, state)
        for i = 1, #oldscr do -- rerender screen in new scale
            for j = 1, #oldscr[i] do
                local pixel = oldscr[i][j]
                if pixel.bg ~= nil then
                    if screen[i] and screen[i][j] then
                        draw(screen, state, i, j, getData(oldscr, state, i, j))
                    end
                    pixel.bg.remove()
                    if pixel.fg then
                        pixel.fg.remove()
                    end
                end
            end
        end
        os.queueEvent("shatter_resize")
    end

    -- compat for all those UK'ers
    out.isColour = out.isColor
    out.setTextColour = out.setTextColor
    out.setBackgroundColour = out.setBackgroundColor
    out.setPaletteColour = out.setPaletteColor
    out.getTextColour = out.getTextColor
    out.getBackgroundColour = out.getBackgroundColor
    out.getPaletteColour = out.getPaletteColor

    local coro = function()
        parallel.waitForAll(function()
            -- cursor flicker
            while true do
                if not state.cb then
                    csr.setText(" ")
                    os.pullEvent("shatter_cursor_blink")
                else
                    csr.setText("_")
                    sleep(.4)
                    csr.setText(" ")
                    sleep(.4)
                end
            end
        end,
        function()
            -- glasses event handler conversion
            while true do
                local e = {os.pullEvent()}
                if e[1]:match("^glasses") then
                    e[1], e[3], e[4] = e[1]:gsub("^glasses", "mouse"), math.ceil(e[3]/state.ox), math.ceil(e[4]/state.oy)
                    os.queueEvent(table.unpack(e))
                end
            end
        end)
    end

    return out, coro
end

return addTerm
