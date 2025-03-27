#include "main.hpp"

Emulator::Emulator() : input_mapper(input_interface), game_pad(input_mapper) {
    LuaBindings::bind_input_interface(&input_interface);
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

    while (running) {
        input_mapper.update();
        game_pad.update();
        input_mapper.zero();
        Sleep(1);
    }

    input_mapper.stop_scripts();
    input_interface.stop();
}

void Emulator::stop() {
    running = false;
}

void Emulator::load_defaults() {
    input_mapper.bind_ls(VKEY_KEYBOARD);
    input_mapper.bind_rs(VKEY_KEYBOARD);
    
    // input_mapper.bind_left_analog(VKEY_W, {0,  1});
    // input_mapper.bind_left_analog(VKEY_A, {-1, 0});
    // input_mapper.bind_left_analog(VKEY_S, {0, -1});
    // input_mapper.bind_left_analog(VKEY_D, {1,  0});
    input_mapper.add_script("./scripts/script1.lua");
    input_interface.bind_flag(VKEY_LEFT_SHIFT, "SUPERGLIDE");

    input_mapper.bind_lt(VKEY_MOUSE_RB);
    input_mapper.bind_rt(VKEY_MOUSE_LB);
    input_mapper.set_sensitivity(0.08f);

    save("./config/default.ukc");
}

void Emulator::save(const char* save_path) {
    json j = input_mapper.export_bytes();

    std::string str = j.dump(2);
    
    File config;
    config.write_buffer(save_path, (BYTE*) str.c_str(), str.length());
    input_mapper.print();
    LOGI("saved to: %s", save_path);
}