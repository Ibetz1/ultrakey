--[bind]SECOND_CROUCH
crouch_binding = EventBinding("SECOND_CROUCH")

tick = 0

function main()
    if crouch_binding == nil then return end

    -- this repeats forever :)
    if KeyDown(Key.SPACE) then
        tick = tick + 1
        PressKey(Key.SPACE)
        ReleaseKey(Key.SPACE)
        
        if (tick > 50) then
            PressKey(crouch_binding)
        end
        
        Wait(10)
    else 
        ReleaseKey(crouch_binding)
    end
end