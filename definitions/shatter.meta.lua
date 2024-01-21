---@meta

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