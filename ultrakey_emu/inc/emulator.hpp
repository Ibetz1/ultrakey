#ifndef _EMULATOR_HPP
#define _EMULATOR_HPP

struct Emulator {
    InputInterface input_interface;
    InputRemapper input_mapper;
    Gamepad game_pad;
    bool running = false;

    Emulator();

    ~Emulator();
    
    void load_config(const char* path);

    void load_defaults();

    void save(const char* save_path = ".");

    void start();

    void stop();
};

#endif