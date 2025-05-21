#ifndef _MNK_CONTEXT_HPP
#define _MNK_CONTEXT_HPP

bool run_mnk(void* data);

void* interception_handler(void* data);

// void* interception_monitor(void* data);

typedef std::function<bool(int, int)> threshold_calc;

bool default_threshold_calc(int x, int y);

struct MouseLerp {
    Vec<float> tot_dist;
    Vec<float> targ_dist;
    float time_ms;
    float accum_ms;
};

struct KeystrokeEvent {
    VirtualKey key;
    int state;
};

struct MnkContext {
    InterceptionContext context = 0;
    InterceptionDevice device = 0;
    InterceptionStroke stroke = { 0 };
    ThreadedQueue<Vec<float>> mouse_events;
    ThreadedQueue<MouseLerp> mouse_outputs;
    ThreadedQueue<KeystrokeEvent> key_outputs;

    volatile bool key_record[VKEY_MAX] = { 0 };
    volatile bool key_block[VKEY_MAX] = { 0 };
    bool intercept = false;

    MnkContext();

    ~MnkContext();

    int handle_keyboard(const InterceptionKeyStroke& keystroke);

    int handle_mouse(const InterceptionMouseStroke &mouseStroke);

    void toggle_intercept(bool v);

    bool key_down(VirtualKey key) const;
    
    void block_key(VirtualKey key, bool do_block);

    void move_mouse(Vec<float> dist, float time_ms);

    void move_cursor(int x, int y, int type);

    void push_key(VirtualKey key, int state);

    void key_stroke(VirtualKey key, int state);

    void pop_events(float dt_ms);
};

#endif