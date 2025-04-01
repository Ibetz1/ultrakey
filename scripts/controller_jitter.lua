--[0,20]JITTER_STRENGTH=8

function main()
    strength = Value("JITTER_STRENGTH")

    if (KeyDown(Key.MOUSE_RB) and KeyDown(Key.MOUSE_LB)) then
        ToggleController(false)
        BlockKey(Key.MOUSE, false)
        MoveCursor(strength, strength)
        Wait(10)
        MoveCursor(-strength, -strength)
        Wait(10)

        if (KeyDown(Key.W)) then
            PressKey(Key.W)
        else
            ReleaseKey(Key.W)
        end

        if (KeyDown(Key.A)) then
            PressKey(Key.A)
        else
            ReleaseKey(Key.A)
        end

        if (KeyDown(Key.S)) then
            PressKey(Key.S)
        else
            ReleaseKey(Key.S)
        end

        if (KeyDown(Key.D)) then
            PressKey(Key.D)
        else
            ReleaseKey(Key.D)
        end
    else
        ToggleController(true)
        BlockKey(Key.MOUSE, true)
        PressButton(Button.GAMEPAD_LEFT_THUMB)
    end
end
