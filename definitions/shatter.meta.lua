---@meta

---@class colormap
local colormap = {
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

---@class Screen
---@field [integer] table<integer, { bg: RectangleObject, fg: TextObject } >

---@class State
---@field can ObjectGroup2D canvas
---@field colormap colormap palette mappings
---@field bg integer background hex color
---@field fg integer foreground hex color 
---@field bgbn integer background color key
---@field fgbn integer foreground color key
---@field bga integer background alpha
---@field fga integer foreground alpha
---@field sx integer default x scale
---@field sy integer default y scale
---@field ox integer current x scale
---@field oy integer current y scale
---@field tx integer terminal x size
---@field ty integer terminal y size
---@field cx integer cursor x
---@field cy integer cursor y
---@field cb boolean cursor blink

---@class ShatterTerm: Term
---@field getTextAlpha fun(): number # get the alpha value for the text, in range 0-1
---@field getBackgroundAlpha fun(): number # get the alpha value for the background, in range 0-1
---@field setTextAlpha fun(alpha: number) # set the alpha value for the text, in range 0-1
---@field setBackgroundAlpha fun(alpha: number) # set the alpha value for the background, in range 0-1
---@field getTextHex fun(): integer # get the color value for the text
---@field getBackgroundHex fun(): integer # get the color value for the background
---@field setTextHex fun(color: integer) # set the color value for the text
---@field setBackgroundHex fun(color: integer) # set the color value for the background
---@field setScale fun(scale: number) # set the text and background pixel scale

---@class ObjectGroup2D
---@field getDocs fun(): table<string, string>
---@field getSize fun(): integer, integer
---@field addRectangle fun(x:number, y:number, width:number, height:number, color:integer): RectangleObject
---@field addText fun(position:{x: number, y: number}, contents:string, color:integer, size:number): TextObject

---@class CanvasObject
---@field getAlpha fun(): integer # returns value in range of 0-255
---@field getColor fun(): integer
---@field getColour fun(): integer
---@field getDocs fun(): table<string, string>
---@field getPosition fun(): number, number
---@field getScale fun(): number
---@field remove fun()
---@field setAlpha fun(alpha: integer) # Accepts values 0-255
---@field setColor fun(color: integer)
---@field setColour fun(color: integer)
---@field setPosition fun(x: number, y: number)
---@field setScale fun(scale: number)

---@class TextObject: CanvasObject
---@field hasShadow fun(): boolean
---@field getText fun(): string
---@field getLineHeight fun(): number
---@field setLineHeight fun(height: number)
---@field setShadow fun(shadow: boolean)
---@field setText fun(text: string)

---@class RectangleObject: CanvasObject