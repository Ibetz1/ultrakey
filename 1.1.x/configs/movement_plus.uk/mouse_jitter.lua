--[0,20]JITTER_STRENGTH=8
strength = Value("JITTER_STRENGTH")

function main()
    if (KeyDown(Key.MOUSE_RB) and KeyDown(Key.MOUSE_LB)) then
        MoveCursor(strength, strength)
        Wait(10)
        MoveCursor(-strength, -strength)
        Wait(10)
    end
end