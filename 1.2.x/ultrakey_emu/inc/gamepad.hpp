#ifndef _GAMEPAD_HPP
#define _GAMEPAD_HPP

void* input_interrupt(Interrupt* interrupt);
void* output_interrupt(Interrupt* interrupt);

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
    
    // vigem
    PVIGEM_CLIENT client;
    PVIGEM_TARGET pad;
    XUSB_REPORT report;

    GamePad(MnkContext* mnk_context);
    ~GamePad();

    Vec<float> run_oscillator(int rev_per_second, float magnitude, float timer);

    Vec<float> mouse_to_stick(float sense);

    Vec<float> get_stick_mapping(VirtualKey binding, const std::unordered_map<VirtualKey, Vec<float>>& stick_bindings);

    Vec<float> key_to_stick(const std::unordered_map<VirtualKey, Vec<float>>& stick_bindings);

    // fuck ass fix for vigem initialization errors
    void init_recurse(int attempts = 0);

    void handle_buttons();

    void handle_toggles();

    void handle_input();

    void handle_osc(float dt_ms, Vec<float>* ls_direction, Vec<float>* rs_direction);

    void send_outputs(float dt_ms);

    void send_zeros();

    bool check_flagged_binding(std::string flag) const;

    int get_flagged_value(std::string flag) const;
};

#endif