# Shatter
Shatter your dull Overlay Glasses experience by turning it into a redirectable terminal target!

Shatter adds several features to the overlay glasses experience beyond a terminal, including a mouse that uses player orientation, and a wireless keyboard server/client arrangment with both secure and insecure variants. It is meant to be used in a neural interface (obviously).

# Brief Rundown

## API
`csrhandler`: handler for cursor positioning and blink, and mouse position and event state. Meant to be put in parallel, or any other multithreading option.
- **Parameters**
  - _none_
- **Returns**
  - _none_

`getTerm`: gives the terminal object once the handler has been activated.
- **Parameters**
  - _none_
- **Returns**
  - _table_: terminal object
  
## Terminal Object
`getAlpha`: get the alpha value for a specific color
- **Parameters**
  - _number_: valid terminal color
- **Returns**
  - _number_: alpha value, in range 0-1
  
`setAlpha`: set the alpha value for a specific color
- **Parameters**
  - _number_: valid terminal color
  - _number_: alpha value within range 0-1
- **Returns**
  - _none_

## Events
  `glass_handler`: fired when the glass handler is loaded
  
  `glass_redirect`: fired when the glass terminal object is requested in `getTerm`

## Mouse
Shatter has a mouse directly built into the terminal software, for convenience sake. It is enabled by default. In the event that you would like to disable the mouse, simply toggle the boolean value "[enabled](https://github.com/hugeblank/Shatter/blob/2e95bc88a4b3095fdf6aff2f5f87484cf07245a2/shatter.lua#L3)"
### Additional Requirements
In order for the mouse to have proper functionality an Entity Sensor and an Introspection Module are required.
### Controls
Controlling the mouse is almost second nature. move your character's head up, down, left, and right to control cursor movement. Don't worry about going too far too the left or right, the mouse conveniently wraps around the edge of the screen so you have 360 degress of control. To click press shift, and to drag hold shift and move head.

# Getting Started
Let's set up all elements of shatter!

## Terminal & Mouse
Obviouslsy you're here for this part so I'll make it as brief as possible.
1. run `wget https://raw.githubusercontent.com/hugeblank/Shatter/master/shatter.lua` on your neural interface that has overlay glasses.
2. If you do not want the mouse, disable it on line 3

# Putting it all Together
Here's an example of how you could put your startup file together:
```
os.loadAPI("shatter.lua") -- Load the shatter API
parallel.waitForAll(shatter.csrhandler,
function()
  os.pullEvent("glass_handler") -- wait for the handler to load
  _G.glass = shatter.getTerm() -- get the terminal object, and put it in the global scope (for alpha setting in the shell)
  term.redirect(glass) -- redirect to overlay
  glass.setAlpha(colors.black, .4) -- set the alpha value of the black color to .4, for visibility.
  term.clear() -- apply the alpha value change
  shell.run("shell") -- run the shell
end,
)
```
