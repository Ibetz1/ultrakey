FPS = 30
released = true

w_was_pressed = false

BlockKey(EventBinding("SUPERGLIDE"), true)

function main()
    if (Event("SUPERGLIDE")) then
        if (released) then
            PressKey(Key.F8)
            ReleaseKey(Key.F8)

            Wait(2)

            PressKey(Key.SPACE)
            Wait(1000 / FPS)
            PressKey(Key.PERIOD)
            ReleaseKey(Key.SPACE)
            ReleaseKey(Key.PERIOD)
            
            Wait(2)

            PressKey(Key.F9)
            ReleaseKey(Key.F9)
        end

        released = false
    else
        released = true
    end
end