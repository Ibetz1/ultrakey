#ifndef _INPUT_REMAPPER_HPP
#define _INPUT_REMAPPER_HPP

struct InputRemapper {

    // normalized data
    std::unordered_map<VirtualKey, InputVector> left_analog_bindings;
    std::unordered_map<VirtualKey, InputVector> right_analog_bindings;
    std::unordered_map<VirtualKey, ButtonCode> button_bindings;
    std::unordered_map<VirtualKey, ToggleMode> toggle_bindings;
    std::vector<std::string> script_paths;
    std::vector<LuaEnvironment*> scripts;
    int internal_clock = 0;
    bool block_controller = false;

    InputVector analog_offset = { 0 };
    InputVector aim_offset = { 0 };
    OutputVector l_n_dxy = { 0 };
    OutputVector r_n_dxy = { 0 };

    OutputVector m_b_dxy = { 0 };
    OutputVector mouse_converstion = { 0 };
    InputVector m_bi_dxy = { 0 };

    // switch data (toggles between 0 and 255)
    VirtualKey lt_binding = VKEY_None;
    VirtualKey rt_binding = VKEY_None;
    VirtualKey ls_binding = VKEY_None;
    VirtualKey rs_binding = VKEY_None;

    // track button press bit field
    USHORT button_presses = 0;

    // interface to get key presses
    InputInterface& itf;

    InputRemapper(InputInterface& itf);
    ~InputRemapper();

    bool intercept_toggled = false;
    bool intercept_held = false;
    bool untoggle_mask = false;
    bool did_toggle_emu = false;

    void update();

    void zero();

    /*
        trigger bindings
    */

    // binds analog keycodes to a normalized vector (typically used for movement)
    void bind_left_analog(VirtualKey key_code, InputVector dir);
    
    void bind_right_analog(VirtualKey key_code, InputVector dir);

    // binds any enumerated button to any virtual key
    void bind_button(VirtualKey key_code, ButtonCode console_code);

    // binds lt to any virtual key
    void bind_lt(VirtualKey binding);

    // binds rt to any virtual key
    void bind_rt(VirtualKey binding);

    // binds ls to either [VKEY_None, VMOUSE or VKEYBOARD]
    void bind_ls(VirtualKey binding);
    
    // binds rs to either [VKEY_None, VMOUSE or VKEYBOARD]
    void bind_rs(VirtualKey binding);

    // presses a gamepad button
    void press_button(ButtonCode button);

    /*
        trigger getters
    */

    // returns lt byte
    BYTE get_lt() const;

    // returns rt byte
    BYTE get_rt() const;

    // returns button bitfield
    USHORT get_button_outputs() const;

    // returns lstick bound output vector
    OutputVector get_lstick() const;

    // returns rstick bound output vector
    OutputVector get_rstick() const;

    /*
        encoding
    */

    // exports to a formatted byte array
    json export_bytes() const;

    // imports formatted byte array into input remapper
    void import_bytes(BYTE* bytes);

    // sets stick sensitivity
    void set_sensitivity(float thres);

    // whether to emulate
    bool do_emulate() const;

    void print();
    
    void toggle_controller(bool v);

    // toggle control
    void bind_hold_toggle(VirtualKey binding);
    void bind_hold_untoggle(VirtualKey binding);
    void bind_click_toggle(VirtualKey binding);

    // scripting support
    void add_script(const char* path);
    void start_scripts();
    void stop_scripts();
};

#endif