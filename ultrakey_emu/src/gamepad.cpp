#include "main.hpp"

Gamepad::Gamepad(const InputRemapper& bindings) : bindings(bindings) {
    client = vigem_alloc();
    if (client == nullptr) {
        THROW("Failed to allocate ViGEm client!\n");
    }

    if (vigem_connect(client) != VIGEM_ERROR_NONE) {
        vigem_free(client);
        THROW("Failed to connect to ViGEm!\n");
    }

    pad = vigem_target_x360_alloc();
    if (pad == nullptr) {
        vigem_disconnect(client);
        vigem_free(client);
        THROW("Failed to allocate Xbox 360 controller!");
    }

    if (vigem_target_add(client, pad) != VIGEM_ERROR_NONE) {
        vigem_target_free(pad);
        vigem_disconnect(client);
        vigem_free(client);
        THROW("Failed to add virtual controller!\n");
    }
}

Gamepad::~Gamepad() {
    vigem_target_remove(client, pad);
    vigem_target_free(pad);
    vigem_disconnect(client);
    vigem_free(client);
}

void Gamepad::update() {
    if (bindings.do_emulate() && !bindings.block_controller) {
        OutputVector lstick_output = bindings.get_lstick();
        OutputVector rstick_output = bindings.get_rstick();

        report.sThumbRX = rstick_output.dx;
        report.sThumbRY = rstick_output.dy;
        report.sThumbLX = lstick_output.dx;
        report.sThumbLY = lstick_output.dy;
        report.bLeftTrigger = bindings.get_lt();
        report.bRightTrigger = bindings.get_rt();
        report.wButtons = bindings.get_button_outputs();
    }

    if (vigem_target_x360_update(client, pad, report) != VIGEM_ERROR_NONE) {
        THROW("Failed to update controller state!\n" );
    }

    ZeroMemory(&report, sizeof(XUSB_REPORT));
}