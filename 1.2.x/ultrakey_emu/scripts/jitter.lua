function main()
    MAX_MS = BoundValue("JITTER_SMOOTHING")
    MAX_DIR = BoundValue("JITTER_STRENGTH")

    if (KeyDown(Key.MOUSE_LB) and KeyDown(Key.MOUSE_RB)) then
        time = 10 + math.floor(MAX_MS * math.random())

        dx = math.floor(MAX_DIR * math.random() - MAX_DIR / 2)
        dy = math.floor(MAX_DIR * math.random() + MAX_DIR / 2)
        LerpMouse(dx *  1, dy *  1, time)
        LerpMouse(dx * -1, dy * -1, time)
    
        Wait(2 * time + 5);
    end
end