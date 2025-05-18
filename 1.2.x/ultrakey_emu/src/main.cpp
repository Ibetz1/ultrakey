#include "main.hpp"

#define SIGNAL_STOP "UKSSP"

#if BUILD_DLL
#define DLL_EXPORT extern "C" __declspec(dllexport)

static volatile bool run = false;
static pthread_t emu_thread;
static char* config_path;

void* emu_main(void* config) {
    run = true;

    MnkContext* mnk_context = new MnkContext();
    GamePad* gamepad_context = new GamePad(mnk_context);

    if (config == nullptr) {
        LOGI("starting ULTRAKEY emulator (load defaults)");
    } else {
        LOGI("load ULTRAKEY emulator %s", (char*) config);
        gamepad_context->import_config((char*) config);
    }

    // gamepad_context->print_config();

    TaskScheduler mnk_scheduler = TaskScheduler(1);
    mnk_scheduler.push(interception_handler, mnk_context, run_mnk);

    TaskScheduler mnk_listener = TaskScheduler(1);
    mnk_listener.push(interception_monitor, mnk_context);

    TaskScheduler gamepad_scheduler = TaskScheduler(1);
    gamepad_scheduler.push(output_handler, gamepad_context);

    TaskScheduler vigem_scheduler = TaskScheduler(1);
    vigem_scheduler.push(gamepad_handler, gamepad_context);

    while (run) { }

    LOGI("emulator stopped");

    mnk_scheduler.stop();
    mnk_listener.stop();
    gamepad_scheduler.stop();
    vigem_scheduler.stop();

    delete mnk_context;
    delete gamepad_context;

    return nullptr;
}

DLL_EXPORT void emu_run_async(char* config) {
    if (run) return;

    if (config_path != nullptr) {
        free(config_path);
        config_path = nullptr;
    }

    config_path = config ? strdup(config) : nullptr;
    run = true;
    
    pthread_create(&emu_thread, nullptr, emu_main, config_path);
}

DLL_EXPORT void emu_stop_async() {
    if (!run) return;

    run = false;
    pthread_join(emu_thread, nullptr);

    if (config_path != nullptr) {
        free(config_path);
        config_path = nullptr;
    }
}

#else

int main(int argc, char* argv[]) {
    WinSignal signals = WinSignal();
    MnkContext* mnk_context = new MnkContext();
    GamePad* gamepad_context = new GamePad(mnk_context);

    if (argc < 2) {
        LOGI("starting ULTRAKEY emulator (load defaults)");
    } else {
        LOGI("load ULTRAKEY emulator %s", argv[1]);
        gamepad_context->import_config(argv[1]);
    }

    // gamepad_context->print_config();

    TaskScheduler mnk_scheduler = TaskScheduler(1);
    mnk_scheduler.push(interception_handler, mnk_context, run_mnk);

    TaskScheduler mnk_listener = TaskScheduler(1);
    mnk_listener.push(interception_monitor, mnk_context);

    TaskScheduler gamepad_scheduler = TaskScheduler(1);
    gamepad_scheduler.push(output_handler, gamepad_context);

    TaskScheduler vigem_scheduler = TaskScheduler(1);
    vigem_scheduler.push(gamepad_handler, gamepad_context);

    signals.add(SIGNAL_STOP, []() {
        THROW("emulator stopped");
    });
    signals.start();
    
    LOGI("end main");
    while (1) { }
    return 0;
}

#endif