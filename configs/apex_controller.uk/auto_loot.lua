--[bind]LOOTING_BIND
--[0,100]SPAM_AFTER=50

looting_bind = EventBinding("LOOTING_BIND")
ticks = 0

function main()
    if Event("LOOTING_BIND") then
        if ticks > Value("SPAM_AFTER") then
            PressKey(looting_bind)
            ReleaseKey(looting_bind)
            Wait(50)
        end

        ticks = ticks + 1
    else
        ticks = 0
    end

    -- this repeats forever :)
end