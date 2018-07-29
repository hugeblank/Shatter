local mods = peripheral.wrap("back")
--ensure all glasses are present
local err, str = false, ""
if not mods.canvas then
    error("Shatter requires Overlay Glasses", 2)
end
local can = mods.canvas()
can.clear()
--colors
local colors = {white = 0xf0f0f0ff, orange = 0xf2b233ff, magenta = 0xe57fd8ff, lightBlue = 0x99b2f2ff, yellow = 0xdede6cff, lime = 0x7fcc19ff, pink = 0xf2b2ccff, gray = 0x4c4c4cff, lightGray = 0x999999ff, cyan = 0x4c99b2ff, purple = 0xb266e5ff, blue = 0x3366ccff, brown = 0x7f664cff, green = 0x57a64eff, red = 0xcc4c4cff, black = 0x191919ff}
--colors by number
local cbn = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}
--term scale
local ox, oy = 6, 9
--term bg and fg colors
local bg, fg, bgbn, fgbn = colors.black, colors.white, 2^(#cbn-1), 2^0
--cursor, pos, and blink
local csr, cx, cy, cb = nil, 1, 1, true
--handler activity, used to ensure cursor is activated before the term is redirected to.
local active = false
--term size
local tx, ty = can.getSize()
tx, ty = math.floor(tx/ox), math.floor(ty/oy)
--screen rendering in a table
local screen = {}
--populate that table
do
    local x, y = can.getSize()
    for i = 0, x, ox do
        screen[#screen+1] = {}
        for j = 0, y, oy do
            screen[#screen][#screen[#screen]+1] = {bg = {}, fg = {}}
        end
    end
end
function handler()
    active = true
    os.queueEvent("shatter_handler")
    os.pullEvent("shatter_redirect")
    parallel.waitForAll(function()
    --cursor flicker
        while true do
            if not cb then
                csr.setText(" ")
            else
                csr.setText("_")
                sleep(.4)
                csr.setText(" ")
            end
            sleep(.4)
        end
    end,
    function()
        --glasses event handler conversion
        while true do
            local e = {os.pullEvent()}
            if e[1]:find("glasses") then
                local _, b = e[1]:find("glasses")
                e[1] = "mouse"..e[1]:sub(b+1, -1)
                if e[1] == "mouse_click" or e[1] == "mouse_up" or e[1] == "mouse_drag" then
                    e[3], e[4] = math.ceil(e[3]/ox), math.ceil(e[4]/oy)
                end
                os.queueEvent(unpack(e))
            end
        end
    end)
end
--write text in grid fashion and add to table
local function write(x, y, char, color)
    x, y = math.floor(x), math.floor(y)
    if x > 0 and y > 0 and x <= tx and y <= ty then
        if screen[x][y].fg.getColor == nil then
            screen[x][y].fg = can.addText({((x-1)*ox)+1, ((y-1)*oy)+1}, char, color)
        else
            screen[x][y].fg.setColor(color)
            screen[x][y].fg.setText(char)
        end
    end
end
--draw pixel in grid fashion and add to table
local function draw(x, y, color)
    x, y = math.floor(x), math.floor(y)
    if x > 0 and y > 0 and x <= tx and y <= ty then
        if screen[x][y].bg.getColor == nil then
            screen[x][y].bg = can.addRectangle((x-1)*ox, (y-1)*oy, ox, oy, color)
        else
            screen[x][y].bg.setColor(color)
        end
    end
end
--get the data of a particular pixel
local function getData(pixel)
    return {bgc = pixel.bg.getColor(),
        fgc = pixel.fg.getColor(),
        txt = pixel.fg.getText()}
end
--set the data of a particular pixel
local function setData(pixel, data)
    local x, y = pixel.bg.getPosition()
    draw((x/ox)+1, (y/oy)+1, data.bgc)
    write((x/ox)+1, (y/oy)+1, data.txt, data.fgc)
end
--move a row to an entirely different line
local function move(line, to)
    if line > 0 and line <= ty and to > 0 and to <= ty then
        local ldata = {}
        for i = 1, tx do
            setData(screen[i][to], getData(screen[i][line]))
        end
    end
end
--populate term with default bg and fg colors.
local function repopulate()
    local x, y = can.getSize()
    for i = 1, math.floor(x/ox) do
        for j = 1, math.floor(y/oy) do
            draw(i, j, bg)
            write(i, j, " ", fg)
        end
    end
end
local out = {}
function getTerm()
    if not active then
        error("cursor handler is not initialized", 0)
    end
    repopulate()
    csr = can.addText({cx*ox, (cy*oy)+1}, "", 0xf0f0f0ff)
    os.queueEvent("shatter_redirect")
    return out
end
out.write = function(str)
--term.write but not as cool.
    str = tostring(str)
    for i = 1, #str do 
        write(cx+i-1, cy, str:sub(i, i), fg)
        draw(cx+i-1, cy, bg)
    end
    cx = cx+#str
end
out.blit = function(str, tfg, tbg)
--term.blit
    if type(str) ~= "string" then
        error("bad argument #1 (expected string, got "..type(str)..")", 2)
    elseif type(tfg) ~= "string" then
        error("bad argument #2 (expected string, got "..type(tfg)..")", 2)
    elseif type(tbg) ~= "string" then
        error("bad argument #3 (expected string, got "..type(tbg)..")", 2)
    end
    for i = 1, #str do
        nfg = cbn[tonumber(tfg:sub(i,i), 16)+1]
        nbg = cbn[tonumber(tbg:sub(i,i), 16)+1]
        draw(cx+i-1, cy, nbg)
        write(cx+i-1, cy, str:sub(i,i), nfg)
    end
    cx = cx+#str
end
out.clear = function()
--term.clear
    for i = 1, tx do
        for j = 1, ty do
            write(i, j, "", fg)
            draw(i, j, bg)
        end
    end
end
out.clearLine = function()
--term.clearLine
    if cy > 0 and cy <= ty then
        for i = 1, tx do
            draw(i, cy, bg)
            write(i, cy, " ", fg)
        end
    end
end
out.getCursorPos = function()
--term.getCursorPos
    return cx, cy
end
out.setCursorPos = function(x, y)
--term.setCursorPos
    if type(x) ~= "number" then
        error("bad argument #1 (expected number, got "..type(x)..")", 2)
    elseif type(y) ~= "number" then
        error("bad argument #2 (expected number, got "..type(y)..")", 2)
    end
    csr.setPosition((x-1)*ox, ((y-1)*oy)+1)
    cx, cy = x, y
end
out.setCursorBlink = function(b)
--term.setCursorBlink
    if type(b) ~= "boolean" then
        error("bad argument #1 (expected boolean, got "..type(b)..")", 2)
    end
    cb = b
end
out.isColor = function()
--term.isColor
    return true, "and 16.8 million at that!"
end
out.isColour = out.isColor
out.getSize = function()
--term.getSize
    return tx, ty
end
out.scroll = function(amount)
--term.scroll
    local tcx, tcy = out.getCursorPos()
    local function swoop(i, amt)
        out.setCursorPos(1, amt)
        out.clearLine()
        move(i, amt)
    end
    if type(amount) ~= "number" then
        error("invalid argument #1 (expected numbe, got "..type(amount)..")", 2)
    end
    if amount > 0 then
        for i = 1, tx do
            out.setCursorPos(1, i-amount)
            out.clearLine()
            move(i, i-amount)
        end
    elseif amount < 0 then
        for i = tx, 1, -1 do
            move(i, i-amount)
            out.setCursorPos(1, i)
            out.clearLine()
        end
    end
    out.setCursorPos(tcx, tcy)
end
local function invCol(col)
--A simple error message I am too lazy to type twice
--used in the following few functions
    error("invalid color (got "..col..")", 2)
end
local function lb2(num)
    return math.log(num)/math.log(2)
end
out.setTextColor = function(col)
--term.setTextColor
    if type(col) ~= "number" then
        error("invalid argument #1 (number expected, got "..type(col)..")", 2)
    end
    if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
        invCol(col)
    else
        fg = cbn[lb2(col)+1]
        fgbn = col
    end
end
out.setBackgroundColor = function(col)
--term.setBackgroundColor
    if type(col) ~= "number" then
        error("invalid argument #1 (expected number, got "..type(col)..")", 2)
    end
    if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
        invCol(col)
    else
        bg = cbn[lb2(col)+1]
        bgbn = col
    end
end
out.getTextColor = function()
--term.getTextColor
    return fgbn
end
out.getBackgroundColor = function()
--term.getBackgroundColor
    return bgbn
end
local function torgba(hex)
    local vals = {}
    for i = 1, 4 do
        vals[i] = hex%256
        hex = (hex-vals[i])/256
    end
    return vals[4]/255, vals[3]/255, vals[2]/255
end
out.getAlpha = function(col)
    if type(col) ~= "number" then
        error("invalid argument #1 (expected number, got "..type(col)..")")
    end
    if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
        invCol(col)
    end
    local c = {torgba(cbn[lb2(col)+1])}
    return  (cbn[lb2(col)+1]-(((c[1]*255)*(16^6))+((c[2]*255)*(16^4))+((c[3]*255)*(16^2))))/255
end
out.setAlpha = function(col, val)
    if type(col) ~= "number" then
        error("invalid argument #1 (number expected, got "..type(col)..")", 2)
    end
    if type(val) ~= "number" then
        error("invalid argument #2 (number expected, got "..type(val)..")", 2)
    end
    if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
        invCol(col)
    end
    if val > 1 then val = 1 end
    local c = {torgba(cbn[lb2(col)+1])}
    cbn[lb2(col)+1] = ((c[1]*255)*(16^6))+((c[2]*255)*(16^4))+((c[3]*255)*(16^2))+math.ceil(val*255)
    if col == bgbn then
        out.setBackgroundColor(bgbn)
    elseif col == fgbn then
        out.setTextColor(fgbn)
    end
end
out.getPaletteColor = function(col)
    if type(col) ~= "number" then
        error("invalid argument #1 (number expected, got "..type(col)..")", 2)
    end
    if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
        invCol(col)
    end
    return torgba(cbn[lb2(col)+1])
end
out.setPaletteColor = function(cnum, r, g, b)
    if type(cnum) ~= "number" then
        error("invalid argument #1 (number expected, god "..type(cnum)..")", 2)
    end
    if type(r) ~= "number" then
        error("invalid argument #2 (number expected, got "..type(r)..")", 2)
    end
    if g then
        if type(g) ~= "number" then
            error("invalid argument #3 (number expected, got "..type(g)..")", 2)
        elseif type(b) ~= "number" then
            error("invalid argument #4 (number expected, got "..type(b)..")", 2)
        end
        if r > 1 then r = 1 end
        if g > 1 then g = 1 end
        if b > 1 then b = 1 end
--        print(r*255, g*255, b*255, ((((r*255)*(16^6))+((g*255)*(16^4))+((b*255)*(16^2)))*256)+255, cbn[lb2(cnum)+1])
        cbn[lb2(cnum)+1] = (((r*255)*(16^6))+((g*255)*(16^4))+((b*255)*(16^2)))+math.ceil(out.getAlpha(cnum)*255)
    else
        cbn[lb2(cnum)+1] = (r*256)+math.ceil(out.getAlpha(cnum)*255)
    end
    if bgbn == cnum then
        out.setBackgroundColor(bgbn)
    elseif fgbn == cnum then
        out.setTextColor(fgbn)
    end
end
out.setTextColour = out.setTextColor
out.setBackgroundColour = out.setBackgroundColor
out.setPaletteColour = out.setPaletteColor
out.getTextColour = out.getTextColor
out.getBackgroundColour = out.getBackgroundColor
out.getPaletteColour = out.getPaletteColor
