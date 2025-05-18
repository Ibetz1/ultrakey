#include <windows.h>
#include "stdio.h"

typedef void (*EmuMain)(char*);
typedef void (*EmuClose)();

int main(int argc, char* argv[]) {
    HMODULE dllHandle = LoadLibraryA("ultrakey_emu.dll");
    if (!dllHandle) {
        printf("failed to load DLL\n");
        return 1;
    }

    EmuMain emu_run_async = (EmuMain)GetProcAddress(dllHandle, "emu_run_async");
    if (!emu_run_async) {
        printf("failed to find emu_main");
        return 1;
    }

    EmuClose emu_stop_async = (EmuClose)GetProcAddress(dllHandle, "emu_stop_async");
    if (!emu_stop_async) {
        printf("failed to find emu_close");
        return 1;
    }

    for (int i = 0; i < 10; ++i) {
        if (argc < 2) {
            emu_run_async(nullptr);
        } else {
            emu_run_async(argv[1]);
        }

        Sleep(1000);

        emu_stop_async();

        Sleep(1000);
    }

    FreeLibrary(dllHandle);
}