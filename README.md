# Shatter

Shatter your dull Overlay Glasses experience by turning it into a redirectable terminal target!

Shatter adds several features to the overlay glasses experience beyond a terminal. It is meant to be used in a neural interface (obviously) with an unbound wireless keyboard.

## Brief Rundown

### API

- **Parameters**
  - _table_: canvas object provided by the overlay glasses
- **Returns**
  - _table_: terminal object
  - _function_: cursor handler function to be put in parallel with your code
  
### Terminal Object

#### Alpha Manipulation

`getTextAlpha`: get the alpha value for the text

- **Parameters**
  - _none_
- **Returns**
  - _number_: alpha value, in range 0-1
  
`getBackgroundAlpha`: get the alpha value for the background

- **Parameters**
  - _none_
- **Returns**
  - _number_: alpha value, in range 0-1
  
`setTextAlpha`: set the alpha value for the text

- **Parameters**
  - _number_: alpha value within range 0-1
- **Returns**
  - _none_
  
`setBackgroundAlpha`: set the alpha value for the background

- **Parameters**
  - _number_: alpha value within range 0-1
- **Returns**
  - _none_

#### Hex Color Manipulation

`setTextHex`: set the text color using any hex color code. Includes rg, and b

- **Parameters**
  - _number_: hex code for color value
- **Returns**
  - _none_
  
`setBackgroundHex`: set the background color using any hex color code. Includes rg, and b

- **Parameters**
  - _number_: hex code for color value
- **Returns**
  - _none_

`getTextHex`: set the text color using any hex color code. Includes rg, and b

- **Parameters**
  - _none_
- **Returns**
  - _number_: hex code for color value
  
`getBackgroundHex`: set the background color using any hex color code. Includes rg, and b

- **Parameters**
  - _none_
- **Returns**
  - _number_: hex code for color value

#### Scaling

`setTextScale`: set the text and background pixel scale

- **Parameters**
  - _number_: scale value within range 0.5-10
- **Returns**
  - _none_

### Events

  `shatter_resize`: fired when the shatter terminal object is resized
  
## Getting Started

Let's set up all elements of shatter!
Obviously you're here for this part so I'll make it as brief as possible.

1. run `wget https://raw.githubusercontent.com/hugeblank/Shatter/master/shatter.lua` on your neural interface that has overlay glasses.
2. Find an unbound wireless keyboard, this functions as both a keyboard & mouse, keep that in mind.

## Putting it all Together

Here's an example of how you could put a startup file together, runs shell on the redirected overlay glasses:

```lua
local shatter = require("shatter") -- Load the shatter API
local mods = peripheral.wrap("back") -- get the modules list
if not mods.canvas then -- ensure glasses are present
  error("Overlay Glasses required") -- error if they aren't there
end
_G.glasses, handler = shatter(mods.canvas()) -- get the terminal object, and put it in the global scope (for alpha setting [and more!] in the shell)
parallel.waitForAll(handler, -- put the handler function in parallel
function()
  term.redirect(glasses) -- redirect to overlay
  glasses.setBackgroundAlpha(.4) -- set the alpha value of the background to .4, for visibility.
  term.clear() -- apply the alpha value change
  if multishell then -- if an advanced computer run multishell
    shell.run("/rom/programs/advanced/multishell.lua")
  else -- otherwise run the shell
    shell.run("shell")
  end
end,
function()
  while true do
    os.pullEvent("shatter_resize") -- check for when the glasses get resized
    os.queueEvent("term_resize") -- apply it to the shell terminal
  end
end)
```
