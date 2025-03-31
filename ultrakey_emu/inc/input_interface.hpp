#ifndef _INPUT_INTERFACE_HPP
#define _INPUT_INTERFACE_HPP

struct InputInterface {
    std::unordered_map<VirtualKey, std::string> tagged_bindings;
    std::unordered_map<std::string, int> value_bindings; 
    InterceptionContext context = 0;
    InterceptionDevice device = 0;
    InterceptionStroke stroke = { 0 };
    InputVector* mouse_output = nullptr;
    bool run_main_loop = false;
    volatile bool key_record[VKEY_MAX] = { 0 };
    volatile bool key_block[VKEY_MAX] = { 0 };
    volatile bool toggle_intercept = false;
    bool auto_threshold = false;
    pthread_t thread = 0;
    pthread_mutex_t rwlock = 0;
    float sense = 0.05f;
    int window_width = 1920;
    int window_height = 1080;

    InputInterface();

    ~InputInterface();

    int handle_keyboard(const InterceptionKeyStroke& keystroke);

    int handle_mouse(const InterceptionMouseStroke &mouseStroke);

    static void* main_loop(void* data);

    void start();

    void stop();

    void bind_mouse_output(InputVector* binding);

    bool key_down(VirtualKey key) const;

    void block(VirtualKey key, bool do_block);

    void push_keystroke(VirtualKey keystroke, int state);

    void move_cursor(int x, int y, int type);

    bool flag_active(std::string) const;

    int get_value(std::string) const;

    void bind_flag(VirtualKey key, std::string binding);
    
    void bind_value(std::string key, int value);

    void offset_analog(float dx, float dy);
};

#endif