#ifndef _GAMEPAD_HPP
#define _GAMEPAD_HPP

void* gamepad_handler(void* data);
void* output_handler(void* data);

struct GamePad {

    // bindings
    Bindings bindings;
    Vec<float> mouse_to_stick_direction = { 0 };
    Vec<float> key_to_stick_direction = { 0 };
    Vec<float> cumu_ls_direction = { 0 };
    Vec<float> cumu_rs_direction = { 0 };
    Vec<float> cumu_thres_direction = { 0 };
    Vec<float> current_ls_direction = { 0 };
    Vec<float> current_rs_direction = { 0 };
    MnkContext* mnk_context;
    USHORT button_presses = 0;

    // state control
    bool intercept_toggled = false;
    bool intercept_held = false;
    bool untoggle_mask = false;
    bool did_toggle_emu = false;
    
    // clock
    Clock input_timer;
    Clock output_timer;

    // vigem
    PVIGEM_CLIENT client;
    PVIGEM_TARGET pad;
    XUSB_REPORT report;

    // lua
    std::vector<LuaScript*> running_scripts;

    GamePad(MnkContext* mnk_context);
    ~GamePad();

    bool threshold_calc(int x, int y);

    Vec<float> run_oscillator(int rev_per_second, float magnitude);

    void mouse_to_stick(Vec<float>* bound_direction, float sense);

    Vec<float> get_stick_mapping(Vec<float>* cumu_dir, VirtualKey binding, const std::unordered_map<VirtualKey, Vec<float>>& stick_bindings);

    Vec<float> key_to_stick(const std::unordered_map<VirtualKey, Vec<float>>& stick_bindings);

    void handle_buttons();

    void handle_toggles();

    void handle_input();

    void send_outputs();

    void send_zeros();

    bool check_flagged_binding(std::string flag) const;

    int get_flagged_value(std::string flag) const;

    void import_config(const char* file);

    void export_config(const char* file);

    void print_config();
};

#endif