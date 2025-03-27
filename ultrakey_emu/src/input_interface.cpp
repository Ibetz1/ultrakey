#include "main.hpp"
 
InputInterface::InputInterface() {
    context = interception_create_context();
    interception_set_filter(context, interception_is_keyboard, INTERCEPTION_FILTER_KEY_DOWN | INTERCEPTION_FILTER_KEY_UP);
    interception_set_filter(context, interception_is_mouse, INTERCEPTION_FILTER_MOUSE_ALL);

    window_width = GetSystemMetrics(SM_CXSCREEN);  // Get screen width
    window_height = GetSystemMetrics(SM_CYSCREEN); // Get screen height
}

InputInterface::~InputInterface() {
    interception_destroy_context(context);
}

int InputInterface::handle_keyboard(const InterceptionKeyStroke& keystroke) {
    int ret = 0;

    // pthread_mutex_lock(&rwlock);

    key_record[keystroke.code] = !keystroke.state;

    if (keystroke.state) {
        ret = 0;
    } else {
        ret = key_block[keystroke.code];
    }
    // pthread_mutex_lock(&rwlock);

    return ret;
}

int InputInterface::handle_mouse(const InterceptionMouseStroke &mouseStroke) {
    int ret = 0;

    // pthread_mutex_lock(&rwlock);
    ret = key_block[VKEY_MOUSE];

    if (mouse_output != nullptr) {
        if (sense > 0) {
            mouse_output->dx =  mouseStroke.x * sense;
            mouse_output->dy = -mouseStroke.y * sense;

            float mag = sqrtf(
                (mouse_output->dx * mouse_output->dx) + 
                (mouse_output->dy * mouse_output->dy)
            );
    
            if (mag > 1.f) {
                if (auto_threshold) {
                    mouse_output->dx = 0.f;
                    mouse_output->dy = 0.f;
                    ret = 0;
                } else {
                    mouse_output->dx /= mag;
                    mouse_output->dy /= mag;
                }
            } else {
                ret = key_block[VKEY_MOUSE];
            }

        } else {
            ret = 0;
        }
    }

    if (mouseStroke.state & INTERCEPTION_MOUSE_LEFT_BUTTON_DOWN) {
        key_record[VKEY_MOUSE_LB] = true;
        ret = key_block[VKEY_MOUSE_LB];
    }

    if (mouseStroke.state & INTERCEPTION_MOUSE_LEFT_BUTTON_UP) {
        key_record[VKEY_MOUSE_LB] = false;
        ret = 0;
    }

    if (mouseStroke.state & INTERCEPTION_MOUSE_RIGHT_BUTTON_DOWN) {
        key_record[VKEY_MOUSE_RB] = true;
        ret = key_block[VKEY_MOUSE_RB];
    }
    if (mouseStroke.state & INTERCEPTION_MOUSE_RIGHT_BUTTON_UP) {
        key_record[VKEY_MOUSE_RB] = false;
        ret = 0;
    }

    if (mouseStroke.state & INTERCEPTION_MOUSE_MIDDLE_BUTTON_DOWN) {
        key_record[VKEY_MOUSE_MB] = true;
        ret = key_block[VKEY_MOUSE_MB];
    }
    if (mouseStroke.state & INTERCEPTION_MOUSE_MIDDLE_BUTTON_UP) {
        key_record[VKEY_MOUSE_MB] = false;
        ret = 0;
    }
    if (mouseStroke.state & INTERCEPTION_MOUSE_WHEEL) {
        key_record[VKEY_MOUSE_MW] = true;
        ret = key_block[VKEY_MOUSE_MW];
    }

    // pthread_mutex_lock(&rwlock);

    return ret;
}

void* InputInterface::main_loop(void* data) {
    InputInterface* blocker = (InputInterface*) data;

    while (
        interception_receive(blocker->context, blocker->device = interception_wait(blocker->context), &blocker->stroke, 1) > 0 
        && blocker->run_main_loop
    ) {
        if (interception_is_keyboard(blocker->device)) {
            InterceptionKeyStroke &keystroke = *(InterceptionKeyStroke *)&blocker->stroke;

            if (blocker->handle_keyboard(keystroke) && blocker->toggle_intercept) {
                continue;
            }
        }

        if (interception_is_mouse(blocker->device)) {
            InterceptionMouseStroke &mouseStroke = *(InterceptionMouseStroke *)&blocker->stroke;

            if (blocker->handle_mouse(mouseStroke) && blocker->toggle_intercept) {
                continue;
            }
        }

        // Forward the event (do not block input)
        interception_send(blocker->context, blocker->device, &blocker->stroke, 1);
    }

    return nullptr;
}

void InputInterface::start() {
    run_main_loop = true;

    if (pthread_create(&thread, NULL, main_loop, this) != 0) {
        THROW("failed to start thread");
    } else {
        LOGI("input interface started");
    }

    pthread_detach(thread);
}

void InputInterface::stop() {
    run_main_loop = false;
    pthread_join(thread, NULL);
}

void InputInterface::bind_mouse_output(InputVector* binding) {
    // pthread_mutex_lock(&rwlock);

    mouse_output = binding;

    // pthread_mutex_lock(&rwlock);
}

bool InputInterface::key_down(VirtualKey key) const {
    // pthread_mutex_lock(&rwlock);
    
    bool out =  key_record[key];

    // pthread_mutex_lock(&rwlock);

    return out;
}

void InputInterface::block(VirtualKey key, bool do_block) {
    // pthread_mutex_lock(&rwlock);

    key_block[key] = do_block;

    // pthread_mutex_lock(&rwlock);
}

void InputInterface::push_keystroke(VirtualKey keystroke, int state) {
    // pthread_mutex_lock(&rwlock);

    InterceptionKeyStroke inst;
    inst.code = keystroke;
    inst.state = state;
    
    // Find a keyboard device
    for (InterceptionDevice dev = 1; dev <= INTERCEPTION_MAX_KEYBOARD; dev++) {
        if (interception_is_keyboard(dev)) {
            int ret = interception_send(context, dev, (InterceptionStroke *)&inst, 1);
            if (ret == 1) {
                break;
            }
        }
    }

    // pthread_mutex_lock(&rwlock);
}

void InputInterface::move_cursor(int x, int y, int type) {
    // pthread_mutex_lock(&rwlock);

    InterceptionMouseStroke inst = {0};

    // Set absolute movement
    inst.state = type;

    // Scale X and Y to 0 - 65535 (full screen range)
    inst.x = x;
    inst.y = y;

    for (InterceptionDevice dev = INTERCEPTION_MAX_KEYBOARD + 1; dev <= INTERCEPTION_MAX_DEVICE; dev++) {
        if (interception_is_mouse(dev)) {
            int ret = interception_send(context, dev, (InterceptionStroke *)&inst, 1);
            if (ret == 1) {
                break;
            }
        }
    }

    // pthread_mutex_lock(&rwlock);
}

bool InputInterface::flag_active(std::string flag) const {
    for (auto & [key, val] : tagged_bindings) {
        if (std::string(flag) == val) {
            return key_down(key);
            break;
        }
    }

    return false;
}

void InputInterface::bind_flag(VirtualKey key, std::string binding) {
    tagged_bindings.insert({key, binding});
}