# Shatter
Shatter your dull Overlay Glasses experience by turning it into a redirectable terminal target!

Shatter adds several features to the overlay glasses experience beyond a terminal. It is meant to be used in a neural interface (obviously) with an unbound wireless keyboard.

# Brief Rundown

## API
`handler`: handler for cursor positioning and blink, and mouse position and event state. Meant to be put in parallel, or any other multithreading option.
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
  `shatter_handler`: fired when the shatter handler is loaded
  
  `shatter_redirect`: fired when the shatter terminal object is requested in `getTerm`
  
# Getting Started
Let's set up all elements of shatter!
Obviously you're here for this part so I'll make it as brief as possible.

1. run `wget https://raw.githubusercontent.com/hugeblank/Shatter/master/shatter.lua` on your neural interface that has overlay glasses.
2. Find an unbound wireless keyboard, this functions as both a keyboard & mouse, keep that in mind.

# Putting it all Together
Here's an example of how you could put your startup file together:
```
os.loadAPI("shatter.lua") -- Load the shatter API
parallel.waitForAll(shatter.handler,
function()
  os.pullEvent("shatter_handler") -- wait for the handler to load
  _G.glasses = shatter.getTerm() -- get the terminal object, and put it in the global scope (for alpha setting in the shell)
  term.redirect(glasses) -- redirect to overlay
  glass.setAlpha(colors.black, .4) -- set the alpha value of the black color to .4, for visibility.
  term.clear() -- apply the alpha value change
  shell.run("shell") -- run the shell
end,
)
```
