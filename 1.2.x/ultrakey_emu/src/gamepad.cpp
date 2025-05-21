#include "main.hpp"

void* input_interrupt(Interrupt* interrupt) {
    static float time = 0.f;
    static int frames = 0;
    float dt_ms = CLK_TIME_CONVERSION(interrupt->dt);

    LuaContext* lua_context = (LuaContext*) interrupt->context;
    GamePad* gamepad = lua_context->gamepad;
    MnkContext* mnk_context = gamepad->mnk_context;

    if (mnk_context->intercept) {
        lua_context->tick();
        gamepad->handle_input();
    }

    gamepad->handle_toggles();

    time += dt_ms;

    frames++;

    if (time > 1000.f) {
        printf("IN-IRQ-FPS: %i, %llu, %llu\n", frames, interrupt->clock, interrupt->last_cycle);
        time = 0.f;
        frames = 0;
    }

    return nullptr;
}

void* output_interrupt(Interrupt* interrupt) {
    static float time = 0.f;
    static int frames = 0;

    GamePad* gamepad = (GamePad*) interrupt->context;
    MnkContext* mnk_context = gamepad->mnk_context;

    float dt_ms = CLK_TIME_CONVERSION(interrupt->dt);

    mnk_context->pop_events(dt_ms);

    if (mnk_context->intercept) {
        gamepad->send_outputs(dt_ms);
    } else {
        gamepad->send_zeros();
    }

    time += dt_ms;
    frames++;

    if (time > 1000.f) {
        printf("OUT-IRQ-FPS: %i, %llu, %llu\n", frames, interrupt->clock, interrupt->last_cycle);
        time = 0.f;
        frames = 0;
    }

    return nullptr;
}

GamePad::GamePad(MnkContext* mnk_context) : mnk_context(mnk_context) {
    client = vigem_alloc();
    if (client == nullptr) {
        THROW("Failed to allocate ViGEm client!\n");
    }

    if (vigem_connect(client) != VIGEM_ERROR_NONE) {
        vigem_free(client);
        THROW("Failed to connect to ViGEm!\n");
    }

    pad = vigem_target_x360_alloc();
    if (pad == nullptr) {
        vigem_disconnect(client);
        vigem_free(client);
        THROW("Failed to allocate Xbox 360 controller!");
    }

    if (vigem_target_add(client, pad) != VIGEM_ERROR_NONE) {
        vigem_target_free(pad);
        vigem_disconnect(client);
        vigem_free(client);
        THROW("Failed to add virtual controller!\n");
    }
}

GamePad::~GamePad() {
    vigem_target_remove(client, pad);
    vigem_target_free(pad);
    vigem_disconnect(client);
    vigem_free(client); 
}

Vec<float> GamePad::run_oscillator(int rev_per_second, float magnitude, float timer) {
    float angle = rev_per_second * 2 * M_PI * timer / 1000.f;
    return Vec<float>::polar(angle, magnitude);
}

Vec<float> GamePad::mouse_to_stick(float sense) {
    Vec<float> event;
    Vec<float> cumulated = { 0 };
    if (mnk_context->mouse_events.try_pop(event)) {
        Vec<float> input = { 0 };

        cumulated.x += event.x * sense;
        cumulated.y += event.y * sense;
    }

    return cumulated.direction();
}

Vec<float> GamePad::get_stick_mapping(
    VirtualKey binding,
    const std::unordered_map<VirtualKey, Vec<float>>& stick_bindings
) {
    if (binding == VKEY_KEYBOARD) {
        Vec<float> stick_offset = key_to_stick(stick_bindings);
        return stick_offset.direction();

    } else if (binding == VKEY_MOUSE) {
        Vec<float> stick_offset = mouse_to_stick(bindings.sensitivity);
        return stick_offset.direction();
    }

    return { 0 };
}

Vec<float> GamePad::key_to_stick(const std::unordered_map<VirtualKey, Vec<float>>& stick_bindings) {
    Vec<float> direction = { 0 };

    for (auto & [binding, dir] : stick_bindings) {
        if (mnk_context->key_down(binding)) {
            direction.add(dir);
        }
    }

    return direction;
}

void GamePad::handle_buttons() {
    for (auto &[key, binding] : bindings.button_bindings)
    {
        if (binding == BCODE_PASS)
        {
            continue;
        }

        button_presses &= ~binding;

        if (mnk_context->key_down(key))
        {
            button_presses |= binding;
            mnk_context->block_key(key, mnk_context->key_block[key] || bindings.enable_passthrough);
        }
    }
}

void GamePad::handle_toggles() {
    intercept_held = false;
    untoggle_mask = false;
    bool single_press_happened = false;
    for (auto [key, mode] : bindings.toggle_bindings)
    {
        bool key_down = mnk_context->key_down(key);

        if (mode == T_MODE_SINGLE_PRESS && key_down)
        {
            if (!did_toggle_emu)
            {
                intercept_toggled = !intercept_toggled;
            }
            single_press_happened = true;
            break;
        }

        if (mode == T_MODE_HOLD)
        {
            if (!intercept_held && key_down)
            {
                intercept_held = true;
            }
        }

        if (mode == T_MODE_HOLD_UNTOGGLE && key_down)
        {
            if (!untoggle_mask && key_down)
            {
                untoggle_mask = true;
            }
        }
    }

    bool before = mnk_context->intercept;
    mnk_context->intercept = (intercept_held || intercept_toggled) && !untoggle_mask;
    bool after = mnk_context->intercept;
    did_toggle_emu = single_press_happened;

    if (before != after)
    {
        LOGI("toggled ultrakey state");
    }
}

void GamePad::handle_input() {
    cumu_ls_direction.add(get_stick_mapping(
        bindings.ls_binding,
        bindings.ls_analog_bindings
    ));

    cumu_rs_direction.add(get_stick_mapping(
        bindings.rs_binding,
        bindings.rs_analog_bindings
    ));

    handle_buttons();

    mnk_context->block_key(bindings.rt_binding, bindings.enable_passthrough);
    mnk_context->block_key(bindings.lt_binding, bindings.enable_passthrough);
    mnk_context->block_key(bindings.ls_binding, bindings.enable_passthrough);
    mnk_context->block_key(bindings.rs_binding, bindings.enable_passthrough);
}

void GamePad::handle_osc(float dt_ms, Vec<float>* ls_direction, Vec<float>* rs_direction) {
    static float timer = 0.f;
    timer += dt_ms;

    // keepalive OSC
    if (bindings.enable_keepalive) {
        Vec<float> osc = run_oscillator(
            bindings.keepalive_speed, 
            bindings.keepalive_strength, 
            timer
        );

        if (bindings.ls_binding == VKEY_KEYBOARD && ls_direction->size() <= 0.1f) {
            ls_direction->add(osc);
        }

        if (bindings.rs_binding == VKEY_KEYBOARD && rs_direction->size() <= 0.1f) {
            rs_direction->add(osc);
        }
    }

    // stablizer OSC
    if (bindings.enable_stabilizer) {
        Vec<float> osc = run_oscillator(
            bindings.stabilizer_speed, 
            bindings.stabilizer_strength, 
            timer
        );

        if (bindings.ls_binding == VKEY_MOUSE) {
            ls_direction->add(osc);
        }

        if (bindings.rs_binding == VKEY_MOUSE) {
            rs_direction->add(osc);
        }
    }

    while (timer > 1000.f) { timer -= 1000.f; }
}

void GamePad::send_outputs(float dt_ms) {
    // VIGEM

    Vec<float> ls_direction = cumu_ls_direction.direction();
    Vec<float> rs_direction = cumu_rs_direction.direction();

    handle_osc(dt_ms, &ls_direction, &rs_direction);

    report.sThumbLX = (SHORT) (fclampf(ls_direction.x, -1.f, 1.f) * (0x7FFE - 1));
    report.sThumbLY = (SHORT) (fclampf(ls_direction.y, -1.f, 1.f) * (0x7FFE - 1));
    report.sThumbRX = (SHORT) (fclampf(rs_direction.x, -1.f, 1.f) * (0x7FFE - 1));
    report.sThumbRY = (SHORT) (fclampf(rs_direction.y, -1.f, 1.f) * (0x7FFE - 1));
    report.bLeftTrigger = (BYTE) mnk_context->key_down(bindings.lt_binding) * 255;
    report.bRightTrigger = (BYTE) mnk_context->key_down(bindings.rt_binding) * 255;
    report.wButtons = button_presses;

    if (vigem_target_x360_update(client, pad, report) != VIGEM_ERROR_NONE) {
        THROW("Failed to update controller state!\n" );
    }

    float ls_decay = 0.f;
    float rs_decay = expf((bindings.stick_smoothing - 1) * dt_ms);

    cumu_ls_direction.mul({ls_decay, ls_decay});
    cumu_rs_direction.mul({rs_decay, rs_decay});


    ZeroMemory(&report, sizeof(XUSB_REPORT));
}

void GamePad::send_zeros() {
    ZeroMemory(&report, sizeof(XUSB_REPORT));
    if (vigem_target_x360_update(client, pad, report) != VIGEM_ERROR_NONE) {
        THROW("Failed to update controller state!\n" );
    }
}

bool GamePad::check_flagged_binding(std::string flag) const {
    for (auto & [key, val] : bindings.tagged_bindings) {
        if (std::string(flag) == val) {
            return mnk_context->key_down(key);
            break;
        }
    }

    return false;
}

int GamePad::get_flagged_value(std::string flag) const {
    if (bindings.value_bindings.count(flag)) {
        return bindings.value_bindings.at(flag);
    }

    return 0;
}