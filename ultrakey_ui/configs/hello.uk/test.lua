ang = 0

function main()
    Wait(10)
    dx = 0
    dy = 0

    if (KeyDown(Key.A)) then
        dx = 0.01
    elseif (KeyDown(Key.D)) then
        dx = -.01
    end

    MoveRStick(dx, dy)

    Wait(10)

    MoveRStick(0, 0)

    -- ang = (ang + 180 / 360)
    -- rad = ang * math.pi    

    -- dx = math.cos(rad)
    -- dy = math.sin(rad)

    -- if KeyDown(Key.MOUSE_RB) then
    --     MoveStick(math.cos(rad) / 2, math.sin(rad) / 4)
    -- else
    --     MoveStick(0, 0)
    -- end

end