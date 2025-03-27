FPS = 144
released = true
space_held = 0

w_was_pressed = false

function main()
    print(EventBinding("SUPERGLIDE"))
    print(EventBinding("TEST"))

    -- if (KeyDown(Key.W)) then
    --     PressKey(Key.W)
    -- else
    --     ReleaseKey(Key.W)
    -- end

    -- if (KeyDown(Key.SPACE)) then
    --     PressKey(Key.SPACE)
    --     ReleaseKey(Key.SPACE)

    --     space_held = space_held + 1

    --     if (space_held > 10) then

    --         if (KeyDown(Key.W)) then
    --             ReleaseKey(Key.W)
    --             PressKey(Key.I)
    --             ReleaseKey(Key.I)
    --             PressKey(Key.PERIOD)
    --         end
        
    --         if (KeyDown(Key.A)) then
    --             ReleaseKey(Key.A)
    --             PressKey(Key.L)
    --             ReleaseKey(Key.L)
    --             PressKey(Key.PERIOD)
    --         end
        
    --         if (KeyDown(Key.S)) then
    --             ReleaseKey(Key.S)
    --             PressKey(Key.K)
    --             ReleaseKey(Key.K)
    --             PressKey(Key.PERIOD)
    --         end
        
    --         if (KeyDown(Key.D)) then
    --             ReleaseKey(Key.D)
    --             PressKey(Key.U)
    --             ReleaseKey(Key.U)
    --             PressKey(Key.PERIOD)
    --         end
            
    --     end
    --     Wait(5)
    -- else
    --     w_was_pressed = false
    --     ReleaseKey(Key.PERIOD)
    --     space_held = 0
    -- end

    -- if (Event("SUPERGLIDE")) then
    --     if (released) then
    --         PressKey(Key.F8)
    --         ReleaseKey(Key.F8)

    --         Wait(5)

    --         PressKey(Key.SPACE)
    --         Wait(1000 / FPS)
    --         PressKey(Key.PERIOD)
    --         ReleaseKey(Key.SPACE)
    --         ReleaseKey(Key.PERIOD)

    --         Wait(5)

    --         PressKey(Key.F9)
    --         ReleaseKey(Key.F9)
    --     end

    --     released = false
    -- else
    --     released = true
    -- end

    -- if (KeyDown(Key.MOUSE_LB)) then
    --     MoveCursor(-8, -8)

    --     Wait(15)

    --     MoveCursor(8, 8)

    --     Wait(15)
    -- end

end