--[bind]SUPERGLIDE
--[bind]LOW_BINDING
--[bind]HIGH_BINDING
--[bind]SECOND_CROUCH

delay = 1000 / 30
pressed = false

while true do
    low_binding = BoundKey("LOW_BINDING")
    high_binding = BoundKey("HIGH_BINDING")
    trigger_binding = BoundKey("SUPERGLIDE")
    crouch_binding = BoundKey("SECOND_CROUCH")

    if low_binding == nil then return end
    if high_binding == nil then return end
    if trigger_binding == nil then return end
    if crouch_binding == nil then return end

    if BindingDown("SUPERGLIDE") then
        if not pressed then
            PressKey(low_binding)

            Wait(10);
            
            PressKey(Key.SPACE)
            Wait(math.floor(delay))
            PressKey(crouch_binding)
            
            ReleaseKey(low_binding)
            PressKey(high_binding)
            ReleaseKey(high_binding)

            Wait(math.floor(2 * delay))

            ReleaseKey(Key.SPACE)
            ReleaseKey(crouch_binding)
    
            pressed = true
        end
    else
        pressed = false
    end

    Wait(10)
end