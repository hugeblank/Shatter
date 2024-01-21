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

`setScale`: set the text and background pixel scale

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
3. Check out the [examples](./examples) directory for demonstrations on how to use shatter.
