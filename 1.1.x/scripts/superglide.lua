--[bind]SUPERGLIDE
--[bind]LOW_BINDING
--[bind]HIGH_BINDING
--[bind]CROUCH

low_binding = EventBinding("LOW_BINDING")
high_binding = EventBinding("HIGH_BINDING")
trigger_binding = EventBinding("SUPERGLIDE")
crouch_binding = EventBinding("CROUCH")
delay = 1000 / 30

pressed = false

function main()
    if low_binding == nil then return end
    if high_binding == nil then return end
    if trigger_binding == nil then return end
    if crouch_binding == nil then return end

    if Event("SUPERGLIDE") then
        if not pressed then
            PressKey(low_binding)
            
            PressKey(Key.SPACE)
            Wait(delay)
            PressKey(crouch_binding)
            
            ReleaseKey(low_binding)
            PressKey(high_binding)
            ReleaseKey(high_binding)

            Wait(2 * delay)

            ReleaseKey(Key.SPACE)
            ReleaseKey(crouch_binding)
    
            pressed = true
        end
    else
        pressed = false
    end
end