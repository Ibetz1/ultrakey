#include "main.hpp"

void Bindings::load_bindings(const char* file_path, LuaContext* lua_context) {
    File file;
    file.read_path(file_path);
    std::string json_data = (char*) file.data();
    json j = json::parse(json_data);

    if (j.contains("left_analog_bindings")) {
        for (const auto& [key, val] : j["left_analog_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            ls_analog_bindings[vkey] = {val[0].get<float>(), val[1].get<float>()};
        }
    }

    if (j.contains("right_analog_bindings")) {
        for (const auto& [key, val] : j["right_analog_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            rs_analog_bindings[vkey] = {val[0].get<float>(), val[1].get<float>()};
        }
    }

    if (j.contains("button_bindings")) {
        for (const auto& [key, val] : j["button_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            button_bindings[vkey] = val.get<ButtonCode>();
        }
    }

    toggle_bindings[VKEY_F10] = T_MODE_SINGLE_PRESS; // static toggle binding
    if (j.contains("toggle_bindings")) {
        for (const auto& [key, val] : j["toggle_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            toggle_bindings[vkey] = val.get<ToggleMode>();
        }
    }

    if (j.contains("tagged_bindings")) {
        for (const auto& [key, val] : j["tagged_bindings"].items()) {
            VirtualKey vkey = (VirtualKey) (std::stoi(key));
            tagged_bindings[vkey] = val.get<std::string>();
        }
    }

    if (j.contains("value_bindings")) {
        for (const auto& [key, val] : j["value_bindings"].items()) {
            value_bindings[key] = val.get<int>();
        }
    }

    scripts = j["scripts"].get<std::vector<std::string>>();
    lt_binding = (VirtualKey)(j.value("lt_binding", lt_binding));
    rt_binding = (VirtualKey)(j.value("rt_binding", rt_binding));
    ls_binding = (VirtualKey)(j.value("ls_binding", ls_binding));
    rs_binding = (VirtualKey)(j.value("rs_binding", rs_binding));

    enable_threshold = (bool)(j.value("threshold",    enable_threshold));
    enable_passthrough= (bool) j.value("passthrough", enable_passthrough);
    enable_stabilizer = (bool) j.value("stabilizer",  enable_stabilizer);
    enable_keepalive = (bool) j.value("keepalive",    enable_keepalive);

    stick_smoothing = (float) (j.value("stick_smoothing", stick_smoothing));
    sensitivity = (float) (j.value("stick_sensitivity", sensitivity));
    stabilizer_strength = (float) (j.value("stabilizer_strength", stabilizer_strength));
    keepalive_strength = (float) (j.value("keepalive_strength", keepalive_strength));
    stabilizer_speed = (float) (j.value("stabilizer_speed", stabilizer_speed));
    keepalive_speed = (float) (j.value("keepalive_speed", keepalive_speed));

    for (std::string script_path : scripts) {
        lua_context->add_script(script_path.c_str());
    }
}

void Bindings::export_bindings(const char* file_path) {
    json j;

    for (auto& [key, val] : ls_analog_bindings) {
        j["left_analog_bindings"][std::to_string(key)] = {val.x, val.y};
    }

    for (auto& [key, val] : rs_analog_bindings) {
        j["right_analog_bindings"][std::to_string(key)] = {val.x, val.y};
    }

    for (auto& [key, val] : button_bindings) {
        j["button_bindings"][std::to_string(key)] = val;
    }

    for (auto& [key, val] : toggle_bindings) {
        j["toggle_bindings"][std::to_string(key)] = val;
    }

    for (auto& [key, val] : tagged_bindings) {
        j["tagged_bindings"][std::to_string(key)] = val;
    }

    for (auto& [key, val] : value_bindings) {
        j["value_bindings"][key] = val;
    }

    j["scripts"] = scripts;
    j["lt_binding"] = lt_binding;
    j["rt_binding"] = rt_binding;
    j["ls_binding"] = ls_binding;
    j["rs_binding"] = rs_binding;

    // toggles
    j["threshold"] = enable_threshold;
    j["passthrough"] = enable_passthrough;
    j["stabilizer"] = enable_stabilizer;
    j["keepalive"] = enable_keepalive;
    
    // settings
    j["stick_smoothing"] = stick_smoothing;
    j["stick_sensitivity"] = sensitivity;
    j["keepalive_strength"] = keepalive_strength;
    j["stabilizer_speed"] = stabilizer_speed;
    j["keepalive_speed"] = keepalive_speed;

    File file;
    std::string json_data = j.dump(2);
    file.write_buffer(file_path, (BYTE*) json_data.c_str(), json_data.length());
}

void Bindings::print_bindings() {
    printf("left_analog_bindings: {");
    for (auto& [key, val] : ls_analog_bindings) {
        printf("%i: (%.4f %.4f), ", key, val.x, val.y);
    }
    printf("}\n");

    printf("right_analog_bindings: {");
    for (auto& [key, val] : rs_analog_bindings) {
        printf("%i: (%.4f %.4f), ", key, val.x, val.y);
    }
    printf("}\n");

    printf("button_bindings: {");
    for (auto& [key, val] : button_bindings) {
        printf("%i: %i, ", key, val);
    }
    printf("}\n");

    printf("toggle_bindings: {");
    for (auto& [key, val] : toggle_bindings) {
        printf("%i: %i, ", key, val);
    }
    printf("}\n");

    printf("tagged_bindings: {");
    for (auto& [key, val] : tagged_bindings) {
        printf("%i: %s, ", key, val.c_str());
    }
    printf("}\n");

    printf("value_bindings: {");
    for (auto& [key, val] : value_bindings) {
        printf("%s: %i, ", key.c_str(), val);
    }
    printf("}\n");

    LOGI("lt_binding = %i", lt_binding);
    LOGI("rt_binding = %i", rt_binding);
    LOGI("ls_binding = %i", ls_binding);
    LOGI("rs_binding = %i", rs_binding);

    LOGI("threshold = %i", enable_threshold);
    LOGI("passthrough = %i", enable_passthrough);
    LOGI("stabilizer = %i", enable_stabilizer);
    LOGI("keepalive = %i", enable_keepalive);

    LOGI("stick_smoothing = %.4f", stick_smoothing);
    LOGI("stick_sensitivity = %.4f", sensitivity);
    LOGI("keepalive_strength = %.4f", keepalive_strength);
    LOGI("keepalive_speed = %i", keepalive_speed);
    LOGI("stabilizer_speed = %i", stabilizer_speed);
}