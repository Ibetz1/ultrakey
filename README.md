# ultrakey

## TODO
- make tutorial videos
    - get clips to daniel

# Key Codes
```lua
Key.None
```
```lua
Key.ESCAPE
```
```lua
Key.N1
```
```lua
Key.N2
```
```lua
Key.N3
```
```lua
Key.N4
```
```lua
Key.N5
```
```lua
Key.N6
```
```lua
Key.N7
```
```lua
Key.N8
```
```lua
Key.N9
```
```lua
Key.N0
```
```lua
Key.MINUS
```
```lua
Key.EQUALS
```
```lua
Key.BACKSPACE
```
```lua
Key.TAB
```
```lua
Key.Q
```
```lua
Key.W
```
```lua
Key.E
```
```lua
Key.R
```
```lua
Key.T
```
```lua
Key.Y
```
```lua
Key.U
```
```lua
Key.I
```
```lua
Key.O
```
```lua
Key.P
```
```lua
Key.LEFT_BRACKET
```
```lua
Key.RIGHT_BRACKET
```
```lua
Key.ENTER
```
```lua
Key.LEFT_CTRL
```
```lua
Key.A
```
```lua
Key.S
```
```lua
Key.D
```
```lua
Key.F
```
```lua
Key.G
```
```lua
Key.H
```
```lua
Key.J
```
```lua
Key.K
```
```lua
Key.L
```
```lua
Key.SEMICOLON
```
```lua
Key.APOSTROPHE
```
```lua
Key.GRAVE
```
```lua
Key.LEFT_SHIFT
```
```lua
Key.BACKSLASH
```
```lua
Key.Z
```
```lua
Key.X
```
```lua
Key.C
```
```lua
Key.V
```
```lua
Key.B
```
```lua
Key.N
```
```lua
Key.M
```
```lua
Key.COMMA
```
```lua
Key.PERIOD
```
```lua
Key.SLASH
```
```lua
Key.RIGHT_SHIFT
```
```lua
Key.KP_MULTIPLY
```
```lua
Key.LEFT_ALT
```
```lua
Key.SPACE
```
```lua
Key.CAPS_LOCK
```
```lua
Key.F1
```
```lua
Key.F2
```
```lua
Key.F3
```
```lua
Key.F4
```
```lua
Key.F5
```
```lua
Key.F6
```
```lua
Key.F7
```
```lua
Key.F8
```
```lua
Key.F9
```
```lua
Key.F10
```
```lua
Key.NUM_LOCK
```
```lua
Key.SCROLL_LOCK
```
```lua
Key.KP_7
```
```lua
Key.KP_8
```
```lua
Key.KP_9
```
```lua
Key.KP_MINUS
```
```lua
Key.KP_4
```
```lua
Key.KP_5
```
```lua
Key.KP_6
```
```lua
Key.KP_PLUS
```
```lua
Key.KP_1
```
```lua
Key.KP_2
```
```lua
Key.KP_3
```
```lua
Key.KP_0
```
```lua
Key.KP_DECIMAL
```
```lua
Key.KP_ENTER
```
```lua
Key.RIGHT_CTRL
```
```lua
Key.KP_DIVIDE
```
```lua
Key.RIGHT_ALT
```
```lua
Key.HOME
```
```lua
Key.UP
```
```lua
Key.PAGE_UP
```
```lua
Key.LEFT
```
```lua
Key.RIGHT
```
```lua
Key.END
```
```lua
Key.DOWN
```
```lua
Key.PAGE_DOWN
```
```lua
Key.INSERT
```
```lua
Key.DELETE
```
```lua
Key.LEFT_WINDOWS
```
```lua
Key.RIGHT_WINDOWS
```
```lua
Key.APPLICATION
```
```lua
Key.MOUSE_LB
```
```lua
Key.MOUSE_RB
```
```lua
Key.MOUSE_MB
```
```lua
Key.MOUSE_MW
```
```lua
Key.MOUSE
```
```lua
Key.KEYBOARD
```

# Button Codes
```lua
Button.GAMEPAD_DPAD_UP
```
```lua
Button.GAMEPAD_DPAD_DOWN
```
```lua
Button.GAMEPAD_DPAD_LEFT
```
```lua
Button.GAMEPAD_DPAD_RIGHT
```
```lua
Button.GAMEPAD_START
```
```lua
Button.GAMEPAD_BACK
```
```lua
Button.GAMEPAD_LEFT_THUMB
```
```lua
Button.GAMEPAD_RIGHT_THUMB
```
```lua
Button.GAMEPAD_LEFT_SHOULDER
```
```lua
Button.GAMEPAD_RIGHT_SHOULDER
```
```lua
Button.GAMEPAD_GUIDE
```
```lua
Button.GAMEPAD_A
```
```lua
Button.GAMEPAD_B
```
```lua
Button.GAMEPAD_X
```
```lua
Button.GAMEPAD_Y
```

# Functions
KeyDown
PressKey
PressButton
BlockKey
ReleaseKey
MoveCursor
Wait
Event
Value
EventBinding
MoveLStick
MoveRStick
ToggleController

# Functions
```lua
KeyDown(Key)                     -> bool
```Returns whether or not  a keycode is pressed

```lua
PressKey(Key)                    -> nil
```
Presses a key until released

```lua
ReleaseKey(Key)                  -> nil
```
Force releases a key

```lua
PressButton(Button)              -> nil
```
Presses a gamepad button, released on next frame

```lua
BlockKey(Key, bool)              -> nil
```
Blocks or unblocks key, blocked/unblocked until next BlockKey call

```lua
MoveCursor(dx, dy)               -> nil
```
Moves cursor dx, dy pixels from current location

```lua
Wait(MS)                         -> nil
```
Waits in MS, high precision but gets shakey under 10MS delay

```lua
Event(string)                    -> bool
```
Returns whether a flagged event is active

```lua
Value(string)                    -> int
```
Returns static value by name

```lua
EventBinding(string)             -> Key
```
Returns what an event is bound to by name

```lua
MoveLStick(dx, dy) -> nil
```
Sets the left stick x and y to dx, dy which are values between 0 and 1, this has 16bit resolution

```lua
MoveRStick(dx [0, 1], dy [0, 1]) -> nil
```
Sets the right stick x and y to dx, dy which are values between 0 and 1, this has 16bit resolution

```lua
ToggleController(bool)           -> nil
```
Sets whether the controller is actively updated