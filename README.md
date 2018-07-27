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
  
## Mouse
Shatter has a mouse directly built into the terminal software, for convenience sake. It is enabled by default. In the event that you would like to disable the mouse, simply toggle the boolean value "[enabled](https://github.com/hugeblank/Shatter/blob/2e95bc88a4b3095fdf6aff2f5f87484cf07245a2/shatter.lua#L3)"
### Additional Requirements
In order for the mouse to have proper functionality an Entity Sensor and an Introspection Module are required.
### Controls
Controlling the mouse is almost second nature. move your character's head up, down, left, and right to control cursor movement. Don't worry about going too far too the left or right, the mouse conveniently wraps around the edge of the screen so you have 360 degress of control. To click press shift, and to drag hold shift and move head.

## Keyboard

### Secure
The secure keyboard software is protected by [SMT][http://www.computercraft.info/forums2/index.php?/topic/29664-smt-secure-modem-transit-for-computercraft/]. This is one of the first programs to be developed with SMT, a secure modem transmission solution by steamp0rt. If you are concerned at all about snoops tapping into your keystrokes, or jerks sending a rogue `rm *`, this is the route for you. In exchange for security, however, the speed and ability to record keystrokes is degraded.

### Insecure
The insecure keyboard software uses rednet transmissions to directly send information. This is the option for if you're not to worried about the security of your neural interface.

# Getting Started
Let's set up all elements of shatter!

## Keyboard
To start we will determine what type of keyboard software we want. To determine that, see "Brief Rundown" > "Keyboard".
Follow *Secure* or *Insecure* once that decision has been made.

### Keystroke Server *Secure*
1. Place down any old computer with a modem on it, and a wireless keyboard bound to it
2. run `pastebin run zpYG4zG1`
3. run server-secure.lua, adding a channel ID for a parameter. Ex: `server-secure 1000`
4. shell.run it in startup if you feel so inclined!

### Keystroke Client *Secure*
1. Aquire a neural interface and connector if you haven't already with a modem in it.
2. run `pastebin run yTQc6T3J`
3. run client-secure.lua, adding a channel ID (the same one you put on the server), and then the servers SMT UUID. (If you do not know what the SMT UUID is I recommend checking ouf the SMT [documentation][https://steamp0rt.github.io/SMT/]) Ex: `client-secure 1000 "789108f4q7"`
4. shell.run in startup if you feel so inclined!

### Keystroke Server *Insecure*
1. Place down any old computer with a modem on it, and a wireless keyboard bound to it
2. run `wget https://raw.githubusercontent.com/hugeblank/Shatter/master/server-insecure.lua`
3. run server-insecure.lua adding your neural interface ID for a parameter. Ex: `server-insecure 1738`
4. shell.run in startup if you feel so inclined!

### Keystroke Client *Insecure*
1. Aquire a neural interface and connector if you haven't already with a modem in it.
2. run `wget https://raw.githubusercontent.com/hugeblank/Shatter/master/client-insecure`
3. run cleint-insecure.lua adding server computer ID for a parameter. Ex: `server-insecure 3187`
4. shell.run in startup if you feel so inclined!

## Terminal & Mouse
Obviouslsy you're here for this part so I'll make it as brief as possible.
1. run `wget https://raw.githubusercontent.com/hugeblank/Shatter/master/shatter.lua` on your neural interface that has overlay glasses.
2. If you do not want the mouse, disable it on line 3

# Putting it all Together
Here's an example of how you could put your startup file together:
```os.loadAPI("shatter.lua")
parallel.waitForAll(shatter.csrhandler,
function()
  os.pullEvent("glass_handler") -- wait for the handler to load
  _G.glass = shatter.getTerm() -- get the terminal object, and put it in the global scope (for alpha setting in the shell)
  term.redirect(glass) -- redirect to overlay
  glass.setAlpha(colors.black, .4) -- set the alpha value of the black color to .4, for visibility.
  shell.run("shell") -- run the shell
end,
function()
  shell.run(<insecure/secure keystroke client>) --insert proper keystroke client here
end
)```
