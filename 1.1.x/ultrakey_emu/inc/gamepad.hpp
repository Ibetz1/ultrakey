#ifndef _GAMEPAD_HPP
#define _GAMEPAD_HPP

struct Gamepad {
    PVIGEM_CLIENT client;
    PVIGEM_TARGET pad;
    XUSB_REPORT report;

    const InputRemapper& bindings;

    Gamepad(const InputRemapper& bindings);

    ~Gamepad();

    void update();
};

#endif