local cce = require("cc.expect")
local expect, range = cce.expect, cce.range
local mods = peripheral.wrap("back")
-- ensure glasses are present
if not mods.canvas then
	error("Shatter requires Overlay Glasses", 2)
end

-- populate that table
local function makeScreen(can, ox, oy)
    local screen = {}
    local x, y = can.getSize()
    for i = 1, math.floor(x / ox) do
        screen[i] = {}
        for j = 1, math.floor(y / oy) do
            screen[i][j] = {}
        end
    end
    return screen
end

-- very basic implementation of base 2 logarithm
local function lb2(num)
	return math.log(num)/math.log(2)
end

-- Converts a hex value into 3 seperate r, g, and b values
local function torgba(hex)
	-- Technically also gets a value, but it thrown out due to what this is needed for
	-- Credit to MC:valithor2 for this algorithm
	local vals = {}
	for i = 1, 4 do
		vals[i] = hex%256
		hex = (hex-vals[i])/256
	end
	return vals[4]/255, vals[3]/255, vals[2]/255
end

--- Creates a shattered terminal
---@param can ObjectGroup2D
---@return ShatterTerm, function
function addTerm(can)

	-- colors, for reference use
	local colors = {
		white = 0xf0f0f000, 
		orange = 0xf2b23300, 
		magenta = 0xe57fd800, 
		lightBlue = 0x99b2f200, 
		yellow = 0xdede6c00, 
		lime = 0x7fcc1900, 
		pink = 0xf2b2cc00, 
		gray = 0x4c4c4c00, 
		lightGray = 0x99999900, 
		cyan = 0x4c99b200, 
		purple = 0xb266e500, 
		blue = 0x3366cc00, 
		brown = 0x7f664c00, 
		green = 0x57a64e00, 
		red = 0xcc4c4c00, 
		black = 0x19191900
	}

	-- colors by number
	local cbn = {
		colors.white,
		colors.orange,
		colors.magenta,
		colors.lightBlue,
		colors.yellow,
		colors.lime,
		colors.pink,
		colors.gray,
		colors.lightGray,
		colors.cyan,
		colors.purple,
		colors.blue,
		colors.brown,
		colors.green,
		colors.red,
		colors.black
	}
	-- default term scale
	local sx, sy = 6, 9

	-- current term scale
	local ox, oy = sx, sy

	-- term bg and fg colors and alpha values
	local bg, fg, bgbn, fgbn, fga, bga, fgabn, bgabn = colors.black, colors.white, 2^(#cbn-1), 2^0, 255, 255, 1, 1

	-- cursor, pos, and blink
	local csr, cx, cy, cb = nil, 1, 1, true --- @type TextObject, integer, integer, boolean

	-- handler activity, used to ensure cursor is activated before the term is redirected to.
	local active = false

	-- term size
	local tx, ty = can.getSize()
	tx, ty = math.floor(tx/ox), math.floor(ty/oy)

	-- screen rendering in a table
	local screen = makeScreen(can, ox, oy)

    -- Table of functions to be outputted
	--- @class ShatterTerm
	local out = {}

	-- write text in grid fashion and add to table
	local function write(x, y, char, color)
		x, y = math.floor(x), math.floor(y)
		if x > 0 and y > 0 and x <= tx and y <= ty then
			if not screen[x][y].fg then
				screen[x][y].fg = can.addText({((x-1)*ox)+1, ((y-1)*oy)+1}, char, color, ox/sx)
			else
				if screen[x][y].fg.getColor() ~= color then
					screen[x][y].fg.setColor(color)
				end
				if screen[x][y].fg.getText() ~= char then
					screen[x][y].fg.setText(char)
				end
			end
		end
	end

	-- draw pixel in grid fashion and add to table
	local function draw(x, y, color)
		x, y = math.floor(x), math.floor(y)
		if x > 0 and y > 0 and x <= tx and y <= ty then
			if not screen[x][y].bg then
				screen[x][y].bg = can.addRectangle((x-1)*ox, (y-1)*oy, ox, oy, color)
			else
				if screen[x][y].bg.getColor() ~= color then
					screen[x][y].bg.setColor(color)
				end
			end
		end
	end

	-- get the data of a particular pixel
	local function getData(pixel)
        if pixel then
			return {
				bgc = bit32.band(pixel.bg.getColor(), 2^32-1), -- Credit to MC:Anavrins for bit32 ingenuity
				fgc = bit32.band(pixel.fg.getColor(), 2^32-1),
				txt = pixel.fg.getText()
			}
		end
	end

	-- set the data of a particular pixel
	local function setData(pixel, data)
		if pixel and data then
			if pixel.bg.getPosition then
				local x, y = pixel.bg.getPosition()
				draw(math.floor(x/ox)+1, math.floor(y/oy)+1, data.bgc)
				write(math.floor(x/ox)+1, math.floor(y/oy)+1, data.txt, data.fgc)
			end
		end
	end

	-- populate term with default bg and fg colors.
    local function repopulate()
		if csr then
			csr.remove()
		end
		local x, y = can.getSize()
		for i = 1, math.floor(x/ox) do
			for j = 1, math.floor(y/oy) do
				draw(i, j, bg)
			end
		end
		for i = 1, math.floor(x/ox) do
			for j = 1, math.floor(y/oy) do
				write(i, j, "", fg)
			end
		end
		csr = can.addText({cx*ox, (cy*oy)+1}, "", 0xffffffff, ox/sx)
	end

	local function refreshColor(oc, nc)
		-- refreshes terminal when palette values are manipulated
		for i = 1, #screen do
			for j = 1, #screen[i] do
				local op, changed = getData(screen[i][j]), false
				if op.bgc == oc then
					op.bgc = nc
					changed = true
				end
				if op.fgc == oc then
					op.fgc = nc
					changed = true
				end
				if changed then
					setData(screen[i][j], op)
				end
			end
		end
	end

	out.write = function(str)
		str = tostring(str)
		for i = 1, #str do
			write(cx+i-1, cy, str:sub(i, i), fg+fga)
			draw(cx+i-1, cy, bg+bga)
		end
		cx = cx+#str
	end

    out.blit = function(str, tfg, tbg)
		expect(1, str, "string")
		expect(2, tfg, "string")
		expect(3, tbg, "string")
		for i = 1, #str do
			nfg = cbn[tonumber(tfg:sub(i,i), 16)+1]
			nbg = cbn[tonumber(tbg:sub(i,i), 16)+1]
			draw(cx+i-1, cy, nbg+bga)
			write(cx+i-1, cy, str:sub(i,i), nfg+fga)
		end
		cx = cx+#str
	end

	out.clear = function()
		for i = 1, tx do
			for j = 1, ty do
				write(i, j, "", fg+fga)
				draw(i, j, bg+bga)
			end
		end
	end

	out.clearLine = function()
		if cy > 0 and cy <= ty then
			for i = 1, tx do
				draw(i, cy, bg+bga)
				write(i, cy, "", fg+fga)
			end
		end
	end

	out.getCursorPos = function()
		return cx, cy
	end

    out.setCursorPos = function(x, y)
		expect(1, x, "number")
		expect(2, y, "number")
		csr.setPosition((x-1)*ox, ((y-1)*oy)+1)
		cx, cy = x, y
	end

	out.setCursorBlink = function(b)
		expect(1, b, "boolean")
		cb = b
	end

	out.isColor = function()
		return true, 0xffffff
	end

	out.getSize = function()
		return tx, ty
	end

    out.scroll = function(amount)
		expect(1, amount, "number")
		local tcx, tcy = out.getCursorPos()
        for i = 1, tx do
			local j = i-amount
			if i > 0 and i <= ty and j > 0 and j <= ty then
				screen[j] = screen[i]
			elseif not (i > 0 and i <= ty) then
				out.setCursorPos(1, i)
				out.clearLine()
			end
		end
	end

	out.setTextColor = function(col)
        expect(1, col, "number")
		local cl = lb2(col)
		if cl > #cbn or cl ~= math.ceil(cl) then
			error("invalid color (got "..col..")", 2)
		else
			fg = cbn[cl+1]
			fgbn = col
			csr.setColor(fg+fga)
		end
	end

	out.setBackgroundColor = function(col)
        expect(1, col, "number")
		local cl = lb2(col)
		if cl > #cbn or cl ~= math.ceil(cl) then
			error("invalid color (got "..col..")", 2)
		else
			bg = cbn[cl+1]
			bgbn = col
		end
	end

	-- Text & BG Alpha innovated by MC:Ale32bit
	out.setTextAlpha = function(val)
		expect(1, val, "number")
		val = math.max(0, math.min(1, val))
		fga = math.floor(val*255)
		fgabn = val
		csr.setAlpha(fga)
	end

	out.setBackgroundAlpha = function(val)
        expect(1, val, "number")
		val = math.max(0, math.min(1, val))
		bga = math.floor(val*255)
		bgabn = val
	end

	out.setTextHex = function(hex)
		expect(1, hex, "number")
		fg = bit32.lshift(hex, 2)
		fgbn = 1
		csr.setColor(fg+fga)
	end

	out.setBackgroundHex = function(hex)
		expect(1, hex, "number")
		bg = bit32.lshift(hex, 2)
		bgbn = 1
	end

	out.getTextColor = function()
		return fgbn
	end

	out.getBackgroundColor = function()
		return bgbn
	end

	out.getTextAlpha = function()
		return fgabn
	end

	out.getBackgroundAlpha = function()
		return bgabn
	end

	out.getTextHex = function()
		return fg
	end

	out.getBackgroundHex = function()
		return bg
	end

	out.getPaletteColor = function(col)
        expect(1, col, "number")
		local cl = lb2(col)
		if cl > #cbn or cl ~= math.ceil(cl) then
			error("invalid color (got "..col..")", 2)
		end
		return torgba(cbn[cl+1])
	end

	out.setPaletteColor = function(cnum, r, g, b)
        -- term.setPaletteColor
		expect(1, cnum, "number")
		expect(2, r, "number")
		expect(3, g, "number")
		expect(4, b, "number")
		local oc = cbn[lb2(cnum)+1]
		if g then
			if r > 1 then r = 1 elseif r < 0 then r = 0 end
			if g > 1 then g = 1 elseif g < 0 then g = 0 end
			if b > 1 then b = 1 elseif b < 0 then b = 0 end
			cbn[lb2(cnum)+1] = (((r*255)*(16^6))+((g*255)*(16^4))+((b*255)*(16^2)))
		else
			cbn[lb2(cnum)+1] = (r*256)
		end
		if bgbn == cnum then
			out.setBackgroundColor(bgbn)
		end
		if fgbn == cnum then
			out.setTextColor(fgbn)
		end
		refreshColor(oc, cbn[lb2(cnum)+1])
	end

    out.setScale = function(scale)
        expect(1, scale, "number")
		range(scale, 0.5, 10)
		ox, oy = math.ceil(scale*sx), math.ceil(scale*sy)
		tx, ty = can.getSize()
		tx, ty = math.floor(tx/ox), math.floor(ty/oy)
		local oldscr = screen -- replicate the screen
		screen = makeScreen(can, ox, oy)
		repopulate() -- add objects
		for i = 1, #oldscr do -- rerender screen in new scale
			for j = 1, #oldscr[i] do
				if oldscr[i][j].bg.getColor ~= nil then
					if screen[i] and screen[i][j] then
						setData(screen[i][j], getData(oldscr[i][j]))
					end
					oldscr[i][j].bg.remove()
					oldscr[i][j].fg.remove()
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

	-- ###TERMINAL CREATION CODE###-- 
	repopulate()
	local coro = function()
		parallel.waitForAll(function()
			-- cursor flicker
			while true do
				if not cb then
					csr.setText(" ")
					sleep()
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
					e[1], e[3], e[4] = e[1]:gsub("^glasses", "mouse"), math.ceil(e[3]/ox), math.ceil(e[4]/oy)
					os.queueEvent(table.unpack(e))
				end
			end
		end)
	end

	return out, coro
end

return addTerm
