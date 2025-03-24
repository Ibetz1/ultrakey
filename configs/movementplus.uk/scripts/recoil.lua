FPS = 30

function main()
    if (KeyDown(Key.MOUSE_LB)) then
        MoveCursor(-8, -8)

        Wait(5)

        MoveCursor(8, 8)

        Wait(5)
    end
end
