#include "main.hpp"

bool default_threshold_calc(int x, int y) {
    return false;
}

bool run_mnk(void* data) {
    MnkContext* context = (MnkContext*) data;

    return interception_receive(
        context->context, 
        context->device = 
        interception_wait(context->context), &context->stroke, 1) 
    > 0;
}

void* interception_handler(void* data) {
    MnkContext* context = (MnkContext*) data;

    if (interception_is_keyboard(context->device)) {
        InterceptionKeyStroke &keystroke = *(InterceptionKeyStroke *)&context->stroke;

        if (context->handle_keyboard(keystroke) && context->intercept) {
            return nullptr;
        }
    }

    if (interception_is_mouse(context->device)) {
        InterceptionMouseStroke &mouseStroke = *(InterceptionMouseStroke *)&context->stroke;

        if (context->handle_mouse(mouseStroke) && context->intercept) {
            return nullptr;
        }
    }

    interception_send(context->context, context->device, &context->stroke, 1);

    return nullptr;
}

void* interception_monitor(void* data) {
    MnkContext* context = (MnkContext*) data;

    context->output_timer.begin();

    context->mouse_outputs.with_front([&](MouseLerp& stroke) -> bool {
        Vec<float> offset = {
            .x = stroke.tot_dist.x + (stroke.targ_dist.x / stroke.time_ms) * context->output_timer.dt_ms,
            .y = stroke.tot_dist.y + (stroke.targ_dist.y / stroke.time_ms) * context->output_timer.dt_ms
        };

        int mouse_dx = (int) offset.x - (int) stroke.tot_dist.x;
        int mouse_dy = (int) offset.y - (int) stroke.tot_dist.y;

        Vec<float> mouse_offset = { (float) mouse_dx, (float) mouse_dy };

        if (mouse_offset.size() > 0.f) {
            context->move_cursor((int) mouse_offset.x, (int) mouse_offset.y, INTERCEPTION_MOUSE_MOVE_RELATIVE);
        }

        stroke.tot_dist.add(offset);
        stroke.accum_ms += context->output_timer.dt_ms;
        stroke.tot_dist = offset;

        if (stroke.accum_ms >= stroke.time_ms || stroke.tot_dist.size() >= stroke.targ_dist.size()) {
            return true;
        }

        return false;
    });

    KeystrokeEvent key_stroke;
    if (context->key_outputs.try_pop(key_stroke)) {
        context->key_stroke(key_stroke.key, key_stroke.state);
    }

    context->output_timer.end(OUTPUT_TARGET_FPS);

    return nullptr;
}

MnkContext::MnkContext() : mouse_events(ThreadedQueue<Vec<float>>()) {
    context = interception_create_context();
    interception_set_filter(context, interception_is_keyboard, INTERCEPTION_FILTER_KEY_DOWN | INTERCEPTION_FILTER_KEY_UP);
    interception_set_filter(context, interception_is_mouse, INTERCEPTION_FILTER_MOUSE_ALL);
}

MnkContext::~MnkContext() {
    interception_destroy_context(context);
}

int MnkContext::handle_keyboard(const InterceptionKeyStroke& keystroke) {
    int ret = 0;

    key_record[keystroke.code] = !keystroke.state;

    if (keystroke.state) {
        ret = 0;
    } else {
        ret = key_block[keystroke.code];
    }

    return ret;
}

int MnkContext::handle_mouse(const InterceptionMouseStroke &mouseStroke) {
    int ret = key_block[VKEY_MOUSE];
    float dx = (float) mouseStroke.x;
    float dy = (float) mouseStroke.y;
    float mag = sqrtf(dx * dx + dy * dy);

    if (auto_thres(dx, dy)) {
        dx = 0;
        dy = 0;
        ret = 1 - mag > 0;
    }

    if (intercept) {
        mouse_events.push({
            .x =  dx,
            .y = -dy,
        });
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

    // if (mouseStroke.state & INTERCEPTION_MOUSE_BUTTON_4_DOWN) {
    //     // key_record[VKEY_MOUSE_MB] = true;
    //     // ret = key_block[VKEY_MOUSE_MB];
    //     ret = false;
    // }

    // if (mouseStroke.state & INTERCEPTION_MOUSE_BUTTON_4_UP) {
    //     // key_record[VKEY_MOUSE_MB] = true;
    //     // ret = key_block[VKEY_MOUSE_MB];
    //     ret = false;
    // }

    // if (mouseStroke.state & INTERCEPTION_MOUSE_BUTTON_5_DOWN) {
    //     // key_record[VKEY_MOUSE_MB] = true;
    //     // ret = key_block[VKEY_MOUSE_MB];
    //     ret = false;
    // }

    // if (mouseStroke.state & INTERCEPTION_MOUSE_BUTTON_5_UP) {
    //     // key_record[VKEY_MOUSE_MB] = true;
    //     // ret = key_block[VKEY_MOUSE_MB];
    //     ret = false;
    // }

    return ret;
}

void MnkContext::toggle_intercept(bool v) {
    intercept = v;
}

bool MnkContext::key_down(VirtualKey key) const {
    bool out = key_record[key];

    return out;
}

void MnkContext::block_key(VirtualKey key, bool do_block) {
    key_block[key] = do_block;
}

void MnkContext::move_mouse(Vec<float> dist, float time_ms) {
    if (dist.size() == 0.0f) {
        return;
    }

    mouse_outputs.push({
        .tot_dist = { 0 },
        .targ_dist = dist,
        .time_ms = time_ms,
    });
}

void MnkContext::move_cursor(int x, int y, int type) {
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
}

void MnkContext::push_key(VirtualKey key, int state) {
    key_outputs.push({
        .key = key,
        .state = state
    });
}

void MnkContext::key_stroke(VirtualKey key, int state) {
    InterceptionKeyStroke inst;
    inst.code = key;
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
}