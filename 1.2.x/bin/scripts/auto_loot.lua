--[bind]LOOTING_BIND
--[0,100]LOOTING_SPAM_AFTER=0
ticks = 0

while true do
    looting_bind = BoundKey("LOOTING_BIND")
    max_ticks = BoundValue("LOOTING_SPAM_AFTER")

    if (looting_bind == nil) then return end;

    if KeyDown(looting_bind) then
        if ticks > max_ticks then
            PressKey(looting_bind)
            ReleaseKey(looting_bind)
        end

        ticks = ticks + 1
    else
        -- ReleaseKey(looting_bind)
        ticks = 0
    end

    Wait(50)
end