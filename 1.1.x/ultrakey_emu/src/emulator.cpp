#include "main.hpp"

Emulator::Emulator() : input_mapper(input_interface), game_pad(input_mapper) {
    LuaBindings::bind_input_interface(&input_interface);
    LuaBindings::bind_remapper(&input_mapper);
}

Emulator::~Emulator() {}

void Emulator::load_config(const char* path) {
    File config;
    config.read_path(path);

    input_mapper.import_bytes(config.data());

    input_mapper.print();
}

void Emulator::start() {
    running = true;

    input_interface.start();
    input_mapper.start_scripts();

    using clock = std::chrono::high_resolution_clock;

    const int target_fps = 600;
    const auto frame_duration = std::chrono::microseconds(1000000 / target_fps);

    int frame_count = 0;
    auto fps_timer = clock::now();

    while (running) {
        auto frame_start = clock::now();

        input_mapper.update();
        game_pad.update();
        input_mapper.zero();

        frame_count++;

        auto now = clock::now();
        if (std::chrono::duration_cast<std::chrono::seconds>(now - fps_timer).count() >= 1) {
            printf("FPS: %i\n", frame_count);
            frame_count = 0;
            fps_timer = now;
        }

        while (clock::now() - frame_start < frame_duration) {
            std::this_thread::yield();
        }
    }

    input_mapper.stop_scripts();
    input_interface.stop();
}

void Emulator::stop() {
    running = false;
}

void Emulator::load_defaults() {
    input_mapper.bind_ls(VKEY_KEYBOARD);
    input_mapper.bind_rs(VKEY_MOUSE);
    
    input_mapper.bind_left_analog(VKEY_W, {0,  1});
    input_mapper.bind_left_analog(VKEY_A, {-1, 0});
    input_mapper.bind_left_analog(VKEY_S, {0, -1});
    input_mapper.bind_left_analog(VKEY_D, {1,  0});

    input_mapper.bind_lt(VKEY_MOUSE_RB);
    input_mapper.bind_rt(VKEY_MOUSE_LB);
    input_mapper.bind_button(VKEY_SPACE, ButtonCode::BCODE_GAMEPAD_A);
    input_mapper.bind_button(VKEY_LEFT_SHIFT, ButtonCode::BCODE_GAMEPAD_LEFT_THUMB);
    input_mapper.set_sensitivity(.09f);
    input_mapper.disable_passthrough = true;
    
    // input_mapper.add_script("./scripts/test.lua");

    // save("./config/default.ukc");
}

void Emulator::save(const char* save_path) {
    json j = input_mapper.export_bytes();

    std::string str = j.dump(2);
    
    File config;
    config.write_buffer(save_path, (BYTE*) str.c_str(), str.length());
    input_mapper.print();
    LOGI("saved to: %s", save_path);
}