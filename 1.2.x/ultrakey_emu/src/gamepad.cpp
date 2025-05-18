#include "main.hpp"

void* gamepad_handler(void* data) {
    GamePad* gamepad = (GamePad*) data;
    MnkContext* mnk_context = gamepad->mnk_context;

    gamepad->output_timer.begin();
    
    if (mnk_context->intercept) {
        gamepad->send_outputs();
    } else {
        gamepad->send_zeros();
    }

    gamepad->output_timer.end(2000);

    return nullptr;
}

void* output_handler(void* data) {
    GamePad* gamepad = (GamePad*) data;
    MnkContext* mnk_context = gamepad->mnk_context;

    gamepad->input_timer.begin();
    gamepad->handle_toggles();
    gamepad->handle_input();

    gamepad->input_timer.end(OUTPUT_TARGET_FPS);

    return nullptr;
}

GamePad::GamePad(MnkContext* mnk_context) : mnk_context(mnk_context) {
    output_timer.show_fps = true;

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

    mnk_context->auto_thres = [&](int x, int y) {
        return this->threshold_calc(x, y);
    };
}

GamePad::~GamePad() {
    for (LuaScript* script : running_scripts) {
        delete script;
    }

    vigem_target_remove(client, pad);
    vigem_target_free(pad);
    vigem_disconnect(client);
    vigem_free(client); 
}

bool GamePad::threshold_calc(int x, int y) {
    return bindings.enable_threshold && cumu_rs_direction.size() >= bindings.auto_thres_threshold;
}

Vec<float> GamePad::run_oscillator(int rev_per_second, float magnitude) {
    float angle = rev_per_second * 2 * M_PI * output_timer.second_timer;
    return Vec<float>::polar(angle, magnitude);
}

void GamePad::mouse_to_stick(Vec<float>* bound_direction, float sense) {
    Vec<float> event;
    if (mnk_context->mouse_events.try_pop(event)) {
        Vec<float> input = { 0 };

        bound_direction->x += event.x * output_timer.dt_ms * sense;
        bound_direction->y += event.y * output_timer.dt_ms * sense;
    }

    float decay = expf((bindings.stick_smoothing - 1) * output_timer.dt_ms);
    bound_direction->mul({decay, decay});
    *bound_direction = bound_direction->direction();
}

Vec<float> GamePad::get_stick_mapping(
    Vec<float>* cumu_dir, 
    VirtualKey binding,
    const std::unordered_map<VirtualKey, Vec<float>>& stick_bindings
) {
    Vec<float> current_dir = { 0 };
    if (binding == VKEY_KEYBOARD) {
        current_dir.add(key_to_stick(stick_bindings));
        
        if (current_dir.size() == 0 && bindings.enable_keepalive) {
            current_dir.add(run_oscillator(
                bindings.keepalive_speed, 
                bindings.keepalive_strength
            ));
        }

        return current_dir.direction();
    } else if (binding == VKEY_MOUSE) {
        mouse_to_stick(cumu_dir, bindings.sensitivity);
        
        if (bindings.enable_stabilizer) {
            current_dir.add(run_oscillator(
                bindings.stabilizer_speed, 
                bindings.stabilizer_strength
            ));
        }

        current_dir.add(*cumu_dir);
        current_dir = current_dir.direction();

        return current_dir;
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
    current_ls_direction = get_stick_mapping(
        &cumu_ls_direction,
        bindings.ls_binding,
        bindings.ls_analog_bindings
    );

    current_rs_direction = get_stick_mapping(
        &cumu_rs_direction,
        bindings.rs_binding,
        bindings.rs_analog_bindings
    );

    handle_buttons();

    mnk_context->block_key(bindings.rt_binding, bindings.enable_passthrough);
    mnk_context->block_key(bindings.lt_binding, bindings.enable_passthrough);
    mnk_context->block_key(bindings.ls_binding, bindings.enable_passthrough);
    mnk_context->block_key(bindings.rs_binding, bindings.enable_passthrough);
}

void GamePad::send_outputs() {

    // VIGEM

    report.sThumbLX = (SHORT) ((current_ls_direction.x) * (0x7FFE - 1));
    report.sThumbLY = (SHORT) ((current_ls_direction.y) * (0x7FFE - 1));
    report.sThumbRX = (SHORT) ((current_rs_direction.x) * (0x7FFE - 1));
    report.sThumbRY = (SHORT) ((current_rs_direction.y) * (0x7FFE - 1));
    report.bLeftTrigger = (BYTE) mnk_context->key_down(bindings.lt_binding) * 255;
    report.bRightTrigger = (BYTE) mnk_context->key_down(bindings.rt_binding) * 255;
    report.wButtons = button_presses;

    if (vigem_target_x360_update(client, pad, report) != VIGEM_ERROR_NONE) {
        THROW("Failed to update controller state!\n" );
    }

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

void GamePad::import_config(const char* file_path) {
    File file;
    file.read_path(file_path);
    std::string json_data = (char*) file.data();
    json j = json::parse(json_data);

    if (j.contains("left_analog_bindings")) {
        for (const auto& [key, val] : j["left_analog_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            bindings.ls_analog_bindings[vkey] = {val[0].get<float>(), val[1].get<float>()};
        }
    }

    if (j.contains("right_analog_bindings")) {
        for (const auto& [key, val] : j["right_analog_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            bindings.rs_analog_bindings[vkey] = {val[0].get<float>(), val[1].get<float>()};
        }
    }

    if (j.contains("button_bindings")) {
        for (const auto& [key, val] : j["button_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            bindings.button_bindings[vkey] = val.get<ButtonCode>();
        }
    }

    if (j.contains("toggle_bindings")) {
        for (const auto& [key, val] : j["toggle_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            bindings.toggle_bindings[vkey] = val.get<ToggleMode>();
        }
    }

    if (j.contains("tagged_bindings")) {
        for (const auto& [key, val] : j["tagged_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            bindings.tagged_bindings[vkey] = val.get<std::string>();
        }
    }

    if (j.contains("value_bindings")) {
        for (const auto& [key, val] : j["value_bindings"].items()) {
            bindings.value_bindings[key] = val.get<int>();
        }
    }

    bindings.scripts = j["scripts"].get<std::vector<std::string>>();
    bindings.lt_binding = (VirtualKey)(j.value("lt_binding", VKEY_NONE));
    bindings.rt_binding = (VirtualKey)(j.value("rt_binding", VKEY_NONE));
    bindings.ls_binding = (VirtualKey)(j.value("ls_binding", VKEY_NONE));
    bindings.rs_binding = (VirtualKey)(j.value("rs_binding", VKEY_NONE));

    bindings.enable_threshold = (bool)(j.value("threshold", false));
    bindings.enable_passthrough= (bool) j.value("passthrough", false);
    bindings.enable_stabilizer = (bool) j.value("stabilizer", false);
    bindings.enable_keepalive = (bool) j.value("keepalive", false);

    bindings.stick_smoothing = (float) (j.value("stick_smoothing", bindings.stick_smoothing));
    bindings.sensitivity = (float) (j.value("stick_sensitivity", bindings.sensitivity));
    bindings.keepalive_strength = (float) (j.value("keepalive_strength", bindings.keepalive_strength));
    bindings.stabilizer_speed = (float) (j.value("stabilizer_speed", bindings.stabilizer_speed));
    bindings.keepalive_speed = (float) (j.value("keepalive_speed", bindings.keepalive_speed));
    
    // export configs
    for (std::string script_path : bindings.scripts) {
        LuaScript* script = new LuaScript(script_path.c_str(), this);
        running_scripts.push_back(script);
    }

    // keep sane values
    // bindings.stick_smoothing = fclampf(bindings.stick_smoothing, 0.8f, 0.99f);
    // bindings.sensitivity = fclampf(bindings.sensitivity, 0.9, 0.99);
    // bindings.stabilizer_strength = fclampf(bindings.sensitivity, 0.01, 0.2);
    // bindings.keepalive_strength = fclampf(bindings.sensitivity, 0.1, 0.5);
    // bindings.stabilizer_speed = clampi(bindings.stabilizer_speed, 10, 360);
    // bindings.stabilizer_speed = clampi(bindings.keepalive_speed, 10, 360);
    bindings.toggle_bindings[VKEY_F10] = T_MODE_SINGLE_PRESS;
}

void GamePad::export_config(const char* file_path) {
    json j;

    for (auto& [key, val] : bindings.ls_analog_bindings) {
        j["left_analog_bindings"][std::to_string(key)] = {val.x, val.y};
    }

    for (auto& [key, val] : bindings.rs_analog_bindings) {
        j["right_analog_bindings"][std::to_string(key)] = {val.x, val.y};
    }

    for (auto& [key, val] : bindings.button_bindings) {
        j["button_bindings"][std::to_string(key)] = val;
    }

    for (auto& [key, val] : bindings.toggle_bindings) {
        j["toggle_bindings"][std::to_string(key)] = val;
    }

    for (auto& [key, val] : bindings.tagged_bindings) {
        j["tagged_bindings"][std::to_string(key)] = val;
    }

    for (auto& [key, val] : bindings.value_bindings) {
        j["value_bindings"][key] = val;
    }

    j["scripts"] = bindings.scripts;
    j["lt_binding"] = bindings.lt_binding;
    j["rt_binding"] = bindings.rt_binding;
    j["ls_binding"] = bindings.ls_binding;
    j["rs_binding"] = bindings.rs_binding;

    // toggles
    j["threshold"] = bindings.enable_threshold;
    j["passthrough"] = bindings.enable_passthrough;
    j["stabilizer"] = bindings.enable_stabilizer;
    j["keepalive"] = bindings.enable_keepalive;
    
    // settings
    j["stick_smoothing"] = bindings.stick_smoothing;
    j["stick_sensitivity"] = bindings.sensitivity;
    j["keepalive_strength"] = bindings.keepalive_strength;
    j["stabilizer_speed"] = bindings.stabilizer_speed;
    j["keepalive_speed"] = bindings.keepalive_speed;

    File file;
    std::string json_data = j.dump(2);
    file.write_buffer(file_path, (BYTE*) json_data.c_str(), json_data.length());
}

void GamePad::print_config() {
    printf("left_analog_bindings: {");
    for (auto& [key, val] : bindings.ls_analog_bindings) {
        printf("%i: (%.4f %.4f), ", key, val.x, val.y);
    }
    printf("}\n");

    printf("right_analog_bindings: {");
    for (auto& [key, val] : bindings.rs_analog_bindings) {
        printf("%i: (%.4f %.4f), ", key, val.x, val.y);
    }
    printf("}\n");

    printf("button_bindings: {");
    for (auto& [key, val] : bindings.button_bindings) {
        printf("%i: %i, ", key, val);
    }
    printf("}\n");

    printf("toggle_bindings: {");
    for (auto& [key, val] : bindings.toggle_bindings) {
        printf("%i: %i, ", key, val);
    }
    printf("}\n");

    printf("tagged_bindings: {");
    for (auto& [key, val] : bindings.tagged_bindings) {
        printf("%i: %s, ", key, val.c_str());
    }
    printf("}\n");

    printf("value_bindings: {");
    for (auto& [key, val] : bindings.value_bindings) {
        printf("%s: %i, ", key.c_str(), val);
    }
    printf("}\n");

    LOGI("lt_binding = %i", bindings.lt_binding);
    LOGI("rt_binding = %i", bindings.rt_binding);
    LOGI("ls_binding = %i", bindings.ls_binding);
    LOGI("rs_binding = %i", bindings.rs_binding);

    LOGI("threshold = %i", bindings.enable_threshold);
    LOGI("passthrough = %i", bindings.enable_passthrough);
    LOGI("stabilizer = %i", bindings.enable_stabilizer);
    LOGI("keepalive = %i", bindings.enable_keepalive);

    LOGI("stick_smoothing = %.4f", bindings.stick_smoothing);
    LOGI("stick_sensitivity = %.4f", bindings.sensitivity);
    LOGI("keepalive_strength = %.4f", bindings.keepalive_strength);
    LOGI("keepalive_speed = %i", bindings.keepalive_speed);
    LOGI("stabilizer_speed = %i", bindings.stabilizer_speed);
}