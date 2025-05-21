#include "main.hpp"

#define SIGNAL_STOP "UKSSP"

#if BUILD_DLL
#define DLL_EXPORT extern "C" __declspec(dllexport)

static volatile bool run = false;
static pthread_t emu_thread;
static char* config_path;

void* emu_main(void* config) {
    run = true;

    InterruptClock* clock = new InterruptClock();
    MnkContext* mnk_context = new MnkContext();
    GamePad* gamepad_context = new GamePad(mnk_context);
    LuaContext* lua_context = new LuaContext(gamepad_context);

    if (config == nullptr) {
        LOGI("starting ULTRAKEY emulator (load defaults)");
    } else {
        LOGI("load ULTRAKEY emulator %s", (char*) config);
        gamepad_context->bindings.load_bindings((char*) config, lua_context);
    }

    TaskScheduler task_manager = TaskScheduler(1);
    task_manager.push(interception_handler, mnk_context, run_mnk);
    clock->push_interrupt(input_interrupt, 20000, lua_context);
    clock->push_interrupt(output_interrupt, 2000, gamepad_context);

    while (run) {
        clock->tick();
    }

    LOGI("emulator stopped");

    task_manager.stop();

    delete mnk_context;
    delete gamepad_context;
    delete lua_context;
    delete clock;

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
    bool run = true;
    
    InterruptClock* clock = new InterruptClock();
    MnkContext* mnk_context = new MnkContext();
    GamePad* gamepad_context = new GamePad(mnk_context);
    LuaContext* lua_context = new LuaContext(gamepad_context);

    if (argc <= 1) {
        LOGI("starting ULTRAKEY emulator (load defaults)");
    } else {
        LOGI("load ULTRAKEY emulator %s", argv[1]);
        gamepad_context->bindings.load_bindings(argv[1], lua_context);
    }

    TaskScheduler task_manager = TaskScheduler(1);
    task_manager.push(interception_handler, mnk_context, run_mnk);
    clock->push_interrupt(input_interrupt, 20000, lua_context);
    clock->push_interrupt(output_interrupt, 2000, gamepad_context);

    while (run) {
        clock->tick();
    }

    LOGI("emulator stopped");

    task_manager.stop();

    delete mnk_context;
    delete gamepad_context;
    delete lua_context;
    delete clock;

    return 0;
}

/*
    gamepad refactor:

    diffuse stick from vigem main
    make 2 threads listening for the key queue and mouse queue
    run osc and keepalive from gamepad main
*/

#endif