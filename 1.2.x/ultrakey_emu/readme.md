# engine:
- dial in scripting
- pre-loading configs (hot keying them)
- live engine changes (controls on the fly)
- response curves 
- add toggle flagged binds
- re-add engine state interfaces to scripting
- look into joy2key, and controller compatibility (new pricing tier)

# ui:
- a graph impl for response curves
- hot keying scripts and configs
- add parser for toggle flagged binds
- config importing/exporting
- better script interface (export, copy, delete, etc.)
- pricing tiers, joy2key, lite, etc
- investigate free trial being managed from the app
- in-game overlays
- take in live feedback from engine
- in-app gamepad tester

# packer:
- auto update (ping github releases)

# front end:
- update API reference page
- update tutorials
   - replace installaion guide
   - simplify config installations with .bat installer(s) and replace config installation vid
   - give a better software overview
- make scripts for auto-install apex cfgs and future game cfgs
- get going on resellers (fatals destiny CFG)
- remove demo section (replace with video)
- start laying ground work for script marketplace, COD etc.

# ideas (way future):
- HWID spoofer
- win boot partition and UEFI driver DMA cheat replacement (big money maker if possible)
- raw accell

# 1.2.3
- updates lua scripts to support mouse buttons


Waits in MS, also yields coroutine (essential at the end of each loop)
```lua
Wait(ms: int)                        -> nil
```

Returns whether or not  a keycode is pressed
```lua
KeyDown(keycode: enum)               -> bool
```

Presses a key until released
```lua
PressKey(keycode: enum)              -> nil
```

Force releases a key
```lua
ReleaseKey(keycode: enum)            -> nil
```

Blocks or unblocks key, blocked/unblocked until next BlockKey call
```lua
BlockKey(keycode: enum, state: bool) -> nil
```

Moves cursor dx, dy pixels from current location over ms period of time
```lua
LerpMouse(dx: int, dy: int, ms: int) -> nil
```

Returns static value by name
```lua
BoundValue(name: str)                -> int (0 if nil)
```

Returns static key by name
```lua
BoundKey(name: str)                  -> key: enum or 0
```

Returns if static key is pressed
```lua
BindingDown(name: str)               -> bool
```