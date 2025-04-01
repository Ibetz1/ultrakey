--[bind]SECOND_CROUCH
crouch_binding = EventBinding("SECOND_CROUCH")

tick = 0

function main()
    if crouch_binding == nil then return end

    if (KeyDown(Key.SPACE)) then
        tick = tick + 1

        if tick > 20 then
            PressKey(crouch_binding)
            PressKey(Key.SPACE)
        end

        if (KeyDown(Key.W)) then
            PressKey(Key.W)
        end
        
        if (KeyDown(Key.A)) then
            PressKey(Key.A)
        end

        if (KeyDown(Key.S)) then
            PressKey(Key.S)
        end

        if (KeyDown(Key.D)) then
            PressKey(Key.D)
        end

        Wait(10)

        if tick > 20 then
            ReleaseKey(Key.SPACE)
        end
        
        ReleaseKey(Key.W)
        ReleaseKey(Key.A)
        ReleaseKey(Key.S)
        ReleaseKey(Key.D)
        -- end
    else
        tick = 0
        ReleaseKey(crouch_binding)
    end

    if KeyDown(Key.W) then
        PressKey(Key.W)
    else
        ReleaseKey(Key.W)
    end

    if KeyDown(Key.A) then
        PressKey(Key.A)
    else
        ReleaseKey(Key.A)
    end

    if KeyDown(Key.S) then
        PressKey(Key.S)
    else
        ReleaseKey(Key.S)
    end

    if KeyDown(Key.D) then
        PressKey(Key.D)
    else
        ReleaseKey(Key.D)
    end
end
