ticks = 0

while true do
    if (KeyDown(Key.E)) then
        if (ticks > 30) then
            PressKey(Key.E)
            ReleaseKey(Key.E)
        end

        ticks = ticks + 1
    else
        ticks = 0
    end

    Wait(50)
end