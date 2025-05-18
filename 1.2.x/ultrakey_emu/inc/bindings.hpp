#ifndef _BINDINGS_HPP
#define _BINDINGS_HPP

struct Bindings {

    // settings
    float stick_smoothing = 0.99f;      // 0.8 -> 0.99
    float sensitivity = 1.f;            // 0.01 -> 2.0
    float stabilizer_strength = 0.032f; // 0.01 -> 0.08
    float keepalive_strength = 0.3;     // 0.1 -> 0.5
    float auto_thres_threshold = 0.95f; // 0.5 -> 0.99
    int stabilizer_speed = 50;          // 10 -> 360
    int keepalive_speed = 120;          // 10 -> 360
    
    // toggles
    bool enable_keepalive = false;
    bool enable_stabilizer = false;
    bool enable_threshold = false;
    bool enable_passthrough = false;

    // static keys
    VirtualKey lt_binding = VKEY_NONE;
    VirtualKey rt_binding = VKEY_NONE;
    VirtualKey ls_binding = VKEY_NONE;
    VirtualKey rs_binding = VKEY_NONE;

    std::unordered_map<VirtualKey, Vec<float>> ls_analog_bindings;
    std::unordered_map<VirtualKey, Vec<float>> rs_analog_bindings;
    std::unordered_map<VirtualKey, ButtonCode> button_bindings;
    std::unordered_map<VirtualKey, ToggleMode> toggle_bindings;
    std::unordered_map<VirtualKey, std::string> tagged_bindings;
    std::unordered_map<std::string, int> value_bindings; 
    std::vector<std::string> scripts;
};

#endif