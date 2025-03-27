#include "main.hpp"

int main(int argc, char* argv[]) {
    Emulator emulator;

    char* save_path = 0;

    if (argc > 2) {
        save_path = (char*) malloc(strlen(argv[2] + 1));
        strcpy(save_path, argv[2]);
    }

    if (argc < 2) {
        LOGI("starting ULTRAKEY emulator (load defaults)");
        emulator.load_defaults();
    } else {
        LOGI("load ULTRAKEY emulator %s", argv[1]);
        emulator.load_config(argv[1]);
    }

    emulator.start();

    return 0;
}