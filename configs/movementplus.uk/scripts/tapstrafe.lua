space_held = 0

function main()


    if (KeyDown(Key.SPACE)) then
        PressKey(Key.SPACE)
        ReleaseKey(Key.SPACE)

        space_held = space_held + 1

        if (space_held > 10) then

            if (KeyDown(Key.W)) then
                ReleaseKey(Key.W)
                PressKey(Key.I)
                ReleaseKey(Key.I)
                PressKey(Key.PERIOD)
            end
        
            if (KeyDown(Key.A)) then
                ReleaseKey(Key.A)
                PressKey(Key.L)
                ReleaseKey(Key.L)
                PressKey(Key.PERIOD)
            end
        
            if (KeyDown(Key.S)) then
                ReleaseKey(Key.S)
                PressKey(Key.K)
                ReleaseKey(Key.K)
                PressKey(Key.PERIOD)
            end
        
            if (KeyDown(Key.D)) then
                ReleaseKey(Key.D)
                PressKey(Key.U)
                ReleaseKey(Key.U)
                PressKey(Key.PERIOD)
            end
            
        end
    else
        if (KeyDown(Key.W)) then
            PressKey(Key.W)
        else
            ReleaseKey(Key.W)
        end

        if (KeyDown(Key.S)) then
            PressKey(Key.S)
        else
            ReleaseKey(Key.S)
        end

        if (KeyDown(Key.D)) then
            PressKey(Key.D)
        else
            ReleaseKey(Key.D)
        end

        if (KeyDown(Key.A)) then
            PressKey(Key.A)
        else
            ReleaseKey(Key.A)
        end

        ReleaseKey(Key.PERIOD)
        space_held = 0
    end
end