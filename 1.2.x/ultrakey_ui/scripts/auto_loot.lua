--[bind]LOOTING_BIND
--[0,100]LOOTING_SPAM_AFTER=0
ticks = 0

function main()
    looting_bind = BoundKey("LOOTING_BIND")

    if (looting_bind == nil) then return end;

    if BindingDown("LOOTING_BIND") then
        if ticks > BoundValue("SPAM_AFTER") then
            PressKey(looting_bind)
            ReleaseKey(looting_bind)
        end

        ticks = ticks + 1
    else
        ReleaseKey(looting_bind)
        ticks = 0
    end

    Wait(50)
end