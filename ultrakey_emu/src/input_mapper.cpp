#include "main.hpp"

InputRemapper::InputRemapper(InputInterface& itf) : itf(itf) 
{
    itf.bind_mouse_output(&m_bi_dxy);
    bind_click_toggle(VKEY_F10);
}

InputRemapper::~InputRemapper() {
    for (auto env : scripts) {
        delete env;
    }
}

#define RING_BUFLEN 18
InputVector accum[RING_BUFLEN] = { 0 };
int tick = 0;

/*
    normalized bindings
*/
void InputRemapper::update() {

    tick = (tick + 1) % RING_BUFLEN;

    /*
        update movement normals
    */
    if (ls_binding == VKEY_KEYBOARD) {
        InputVector normalizedVector = analog_offset;
        for (auto & [key, vector] : left_analog_bindings) {
            if (itf.key_down(key)) {
                normalizedVector.dx += vector.dx;
                normalizedVector.dy += vector.dy;
            }
    
            itf.block(key, true);
        }
    
        float magnitude = sqrtf(
            (normalizedVector.dx * normalizedVector.dx) + (normalizedVector.dy * normalizedVector.dy)
        );

        if (magnitude > 1.f) {
            normalizedVector.dx /= magnitude;
            normalizedVector.dy /= magnitude;
        }
    
        l_n_dxy.dx = fclampf(normalizedVector.dx, -1.f, 1.f) * S16_lim;
        l_n_dxy.dy = fclampf(normalizedVector.dy, -1.f, 1.f) * S16_lim;
    }

    if (rs_binding == VKEY_KEYBOARD) {
        InputVector normalizedVector = analog_offset;
        for (auto & [key, vector] : right_analog_bindings) {
            if (itf.key_down(key)) {
                normalizedVector.dx += vector.dx;
                normalizedVector.dy += vector.dy;
            }
    
            itf.block(key, true);
        }
    
        float magnitude = sqrtf(
            (normalizedVector.dx * normalizedVector.dx) + (normalizedVector.dy * normalizedVector.dy)
        );

        if (magnitude > 1.f) {
            normalizedVector.dx /= magnitude;
            normalizedVector.dy /= magnitude;
        }
    
        r_n_dxy.dx = fclampf(normalizedVector.dx, -1.f, 1.f) * S16_lim;
        r_n_dxy.dy = fclampf(normalizedVector.dy, -1.f, 1.f) * S16_lim;
    }

    /*
        update button bindings
    */
    bool htoggle = true;
    for (auto & [key, binding] : button_bindings) {
        if (binding == BCODE_PASS) {
            continue;
        }

        button_presses &= ~binding;

        if (itf.key_down(key)) {
            button_presses |= binding;
            itf.block(key, true);
        }
    }

    /*
        check toggle
    */
    intercept_held = false;
    untoggle_mask = false;
    bool single_press_happened = false;
    for (auto [key, mode] : toggle_bindings) {
        bool key_down = itf.key_down(key);

        if (mode == T_MODE_SINGLE_PRESS && key_down) {
            if (!did_toggle_emu) {
                intercept_toggled = !intercept_toggled;
            }
            single_press_happened = true;
            break;
        }

        if (mode == T_MODE_HOLD) {
            if (!intercept_held && key_down) {
                intercept_held = true;
            }
        }

        if (mode == T_MODE_HOLD_UNTOGGLE && key_down) {
            if (!untoggle_mask && key_down) {
                untoggle_mask = true;
            }
        }
    }

    bool before = itf.toggle_intercept;
    itf.toggle_intercept = (intercept_held || intercept_toggled) && !untoggle_mask;
    bool after = itf.toggle_intercept;
    did_toggle_emu = single_press_happened;
    
    if (before != after) {
        LOGI("toggled ultrakey state");
    }

    accum[tick] = m_bi_dxy;

    InputVector avg = { 0 };
    for (int i = 0; i < RING_BUFLEN; ++i) {
        avg.dx += accum[i].dx / (float) RING_BUFLEN;
        avg.dy += accum[i].dy / (float) RING_BUFLEN;
    }

    /*
        cycle oscillator
    */
    m_b_dxy.dx = (short) (fclampf(avg.dx + aim_offset.dx, -1.f, 1.f) * S16_lim);
    m_b_dxy.dy = (short) (fclampf(avg.dy + aim_offset.dy, -1.f, 1.f) * S16_lim);

    /*
        update block
    */
    // itf.block(rt_binding, true);
    // itf.block(lt_binding, true);
    // itf.block(ls_binding, true);
    // itf.block(rs_binding, true);
}

/*
    zero input mapper (basically a reset state)
*/
void InputRemapper::zero() {
    m_bi_dxy.dx = 0.f;
    m_bi_dxy.dy = 0.f;
}

/*
    trigger bindings
*/
void InputRemapper::bind_left_analog(VirtualKey key_code, InputVector dir) {
    left_analog_bindings.insert({key_code, dir});
}

void InputRemapper::bind_right_analog(VirtualKey key_code, InputVector dir) {
    right_analog_bindings.insert({key_code, dir});
}

void InputRemapper::bind_button(VirtualKey key_code, ButtonCode console_code) {
    button_bindings.insert({key_code, console_code});
}

void InputRemapper::bind_ls(VirtualKey binding) {
    ls_binding = binding;
}

void InputRemapper::bind_rs(VirtualKey binding) {
    rs_binding = binding;
}

void InputRemapper::bind_lt(VirtualKey binding) {
    lt_binding = binding;
}

void InputRemapper::bind_rt(VirtualKey binding) {
    rt_binding = binding;
}

/*
    trigger getters
*/
BYTE InputRemapper::get_lt() const {
    return (BYTE) (itf.key_down(lt_binding) * 255);
}

BYTE InputRemapper::get_rt() const {
    return (BYTE) (itf.key_down(rt_binding) * 255);
}

USHORT InputRemapper::get_button_outputs() const {
    return button_presses;
}

void InputRemapper::press_button(ButtonCode button) {
    button_presses |= button;
}

OutputVector InputRemapper::get_lstick() const {
    if (ls_binding == VKEY_MOUSE) {
        return m_b_dxy;
    }

    if (ls_binding == VKEY_KEYBOARD) {
        return l_n_dxy;
    }

    return { 0 };
}

OutputVector InputRemapper::get_rstick() const {
    if (rs_binding == VKEY_MOUSE) {
        return m_b_dxy;
    }

    if (rs_binding == VKEY_KEYBOARD) {
        return r_n_dxy;
    }

    return { 0 };
}

json InputRemapper::export_bytes() const {
    json j;

    for (auto & [key, dir] : left_analog_bindings) {
        j["left_analog_bindings"][std::to_string(key)] = {dir.dx, dir.dy};
    }

    for (auto & [key, dir] : right_analog_bindings) {
        j["right_analog_bindings"][std::to_string(key)] = {dir.dx, dir.dy};
    }

    for (auto & [key, button] : button_bindings) {
        j["button_bindings"][std::to_string(key)] = button;
    }

    for (auto & [key, mode] : toggle_bindings) {
        j["toggle_bindings"][std::to_string(key)] = mode;
    }

    for (auto & [key, mode] : itf.tagged_bindings) {
        j["tagged_bindings"][std::to_string(key)] = mode;
    }

    for (auto & [key, val] : itf.value_bindings) {
        j["value_bindings"][key] = val;
    }

    j["scripts"] = script_paths;

    j["lt_binding"] = lt_binding;
    j["rt_binding"] = rt_binding;
    j["ls_binding"] = ls_binding;
    j["rs_binding"] = rs_binding;

    j["threshold"] = itf.auto_threshold;
    j["sensitivity"] = itf.sense;

    return j;
}

void InputRemapper::import_bytes(BYTE* bytes) {
    std::string json_data((char*) bytes);

    json j = json::parse(json_data);

    // Load Analog Bindings
    if (j.contains("left_analog_bindings")) {
        for (const auto& [key, value] : j["left_analog_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            left_analog_bindings[vkey] = (InputVector) {value[0], value[1]};
        }
    }

    if (j.contains("right_analog_bindings")) {
        for (const auto& [key, value] : j["right_analog_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            right_analog_bindings[vkey] = (InputVector) {value[0], value[1]};
        }
    }

    if (j.contains("button_bindings")) {
        for (const auto& [key, value] : j["button_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            button_bindings[vkey] = value;
        }
    }

    if (j.contains("toggle_bindings")) {
        for (const auto& [key, value] : j["toggle_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            toggle_bindings[vkey] = value;
        }
    }

    if (j.contains("tagged_bindings")) {
        for (const auto& [key, value] : j["tagged_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            itf.bind_flag(vkey, value);
        }
    }

    if (j.contains("value_bindings")) {
        for (const auto& [key, value] : j["value_bindings"].items()) {
            int val = value.get<int>();
            itf.bind_value(key, val);
        }
    }

    std::vector<std::string> scripts = j["scripts"].get<std::vector<std::string>>();

    for (auto p : scripts) {
        add_script(p.c_str());
    }

    lt_binding = (VirtualKey) (j.value("lt_binding", VKEY_None));
    rt_binding = (VirtualKey) (j.value("rt_binding", VKEY_None));
    ls_binding = (VirtualKey) (j.value("ls_binding", VKEY_None));
    rs_binding = (VirtualKey) (j.value("rs_binding", VKEY_None));
    
    itf.auto_threshold = (bool) (j.value("threshold", 0));
    set_sensitivity(j.value("sensitivity", itf.sense));

    LOGI("loaded config data");
}

void InputRemapper::set_sensitivity(float thres) {
    itf.sense = thres;
}

void InputRemapper::bind_hold_toggle(VirtualKey binding) {
    toggle_bindings.insert({binding, T_MODE_HOLD});
}

void InputRemapper::bind_click_toggle(VirtualKey binding) {
    toggle_bindings.insert({binding, T_MODE_SINGLE_PRESS});
}

void InputRemapper::bind_hold_untoggle(VirtualKey binding) {
    toggle_bindings.insert({binding, T_MODE_HOLD_UNTOGGLE});
}

bool InputRemapper::do_emulate() const {
    return itf.toggle_intercept;
}

void InputRemapper::print() {
    for (auto & [key, dir] : left_analog_bindings) {
        LOGI("%i: {%.2f %.2f} ", key, dir.dx, dir.dy);
    }

    for (auto & [key, dir] : right_analog_bindings) {
        LOGI("%i: {%.2f %.2f} ", key, dir.dx, dir.dy);
    }

    for (auto & [key, binding] : button_bindings) {
        LOGI("%i: %i ", key, binding);
    }

    for (auto & [key, binding] : itf.tagged_bindings) {
        LOGI("%i: %s ", key, binding.c_str());
    }

    LOGI("LT binding: %i", lt_binding);
    LOGI("RT binding: %i", rt_binding);
    LOGI("LS binding: %i", ls_binding);
    LOGI("RS binding: %i", rs_binding);

    LOGI("sense %.4f", itf.sense);
    LOGI("threshold %i", itf.auto_threshold);
}

void InputRemapper::add_script(const char* path) {
    LuaEnvironment* environment = new LuaEnvironment(path);
    scripts.push_back(environment);
    script_paths.push_back(std::string(path));
    LOGI("added scripts %s", path);
}

void InputRemapper::start_scripts() {
    for (auto script : scripts) {
        script->start();
    }
}

void InputRemapper::stop_scripts() {
    for (auto script : scripts) {
        script->stop();
    }
}

void InputRemapper::toggle_controller(bool v) {
    block_controller = !v;
}