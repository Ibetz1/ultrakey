--[1,50]JITTER_STRENGTH=10
strength = Value("JITTER_STRENGTH")

tick = 0
tick_max = 5

function round(x)
    if x >= 0 then
        return math.floor(x + 0.5)
    else
        return math.ceil(x - 0.5)
    end
end

function main()
    BlockKey(Key.W, true)
    BlockKey(Key.A, true)
    BlockKey(Key.S, true)
    BlockKey(Key.D, true)

    tick = tick + 1
    if tick > tick_max then
        tick = 0
    end
    rad = (tick / tick_max) * 2 * math.pi
    dir = round(math.sin(rad))
    cnt = math.abs(dir) * strength

    if (KeyDown(Key.MOUSE_RB) and KeyDown(Key.MOUSE_LB)) then
        for i = 1,cnt do
            MoveCursor(dir, dir)
        end
    end
end