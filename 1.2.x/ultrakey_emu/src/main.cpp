#include "main.hpp"

#define SIGNAL_STOP "UKSSP"

#if BUILD_DLL == true
#define DLL_EXPORT extern "C" __declspec(dllexport)

static volatile bool run = false;
static pthread_t emu_thread;
static char* config_path;

static pthread_mutex_t emu_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t emu_cond = PTHREAD_COND_INITIALIZER;
static bool emu_initialized = false;

static InterruptClock* interrupt_clock = nullptr;
static MnkContext* mnk_context = nullptr;
static GamePad* gamepad_context = nullptr;
static LuaContext* lua_context = nullptr;

void throw_message_popup(const char* fmt, ...) {
    char buffer[1024];
    
    va_list args;
    va_start(args, fmt);
    vsnprintf(buffer, sizeof(buffer), fmt, args); // Safe formatting
    va_end(args);
    
    run = false;
    MessageBoxA(
        nullptr,
        buffer,
        "Error",
        MB_ICONERROR | MB_OK
    );
}

void* emu_main(void* config) {
    pthread_mutex_lock(&emu_mutex);
    run = true;

    interrupt_clock = new InterruptClock();
    mnk_context = new MnkContext();
    gamepad_context = new GamePad(mnk_context);
    lua_context = new LuaContext(gamepad_context);

    if (config == nullptr) {
        LOGI("starting ULTRAKEY emulator");
    } else {
        LOGI("load ULTRAKEY emulator %s", (char*) config);
        gamepad_context->bindings.load_bindings((char*) config);
        gamepad_context->bindings.load_scripts((char*) config, lua_context);
    }

    emu_initialized = true;
    pthread_cond_broadcast(&emu_cond);
    pthread_mutex_unlock(&emu_mutex);

    TaskScheduler task_manager = TaskScheduler(1);
    task_manager.push(interception_handler, mnk_context, run_mnk);
    interrupt_clock->push_interrupt(input_interrupt, 20000, lua_context);
    interrupt_clock->push_interrupt(output_interrupt, 2000, gamepad_context);

    while (run) {
        interrupt_clock->tick();
    }

    LOGI("emulator stopped");

    task_manager.stop();

    pthread_mutex_lock(&emu_mutex);
    delete mnk_context; mnk_context = nullptr;
    delete gamepad_context; gamepad_context = nullptr;
    delete lua_context; lua_context = nullptr;
    delete interrupt_clock; interrupt_clock = nullptr;

    emu_initialized = false;
    pthread_mutex_unlock(&emu_mutex);

    return nullptr;
}

static void wait_for_emu_ready() {
    pthread_mutex_lock(&emu_mutex);
    while (!emu_initialized) {
        pthread_cond_wait(&emu_cond, &emu_mutex);
    }
    pthread_mutex_unlock(&emu_mutex);
}

DLL_EXPORT void emu_push_config(char* config) {
    wait_for_emu_ready();
    if (gamepad_context != nullptr) {
        gamepad_context->bindings.load_json(config);
    } else {
        THROW("invalid gamepad context");
    }
}

DLL_EXPORT void emu_push_script(char* source) {
    wait_for_emu_ready();
    if (lua_context != nullptr) {
        lua_context->add_source(source);
    } else {
        THROW("invalid lua context");
    }
}

DLL_EXPORT void emu_run_config_async(char* config) {
    if (run) return;

    if (config_path != nullptr) {
        free(config_path);
        config_path = nullptr;
    }

    config_path = config ? strdup(config) : nullptr;
    run = true;

    pthread_create(&emu_thread, nullptr, emu_main, config_path);
}

DLL_EXPORT void emu_run_async() {
    if (run) return;
    run = true;

    pthread_create(&emu_thread, nullptr, emu_main, config_path);
}

DLL_EXPORT void emu_stop_async() {
    if (!run) return;

    run = false;
    pthread_join(emu_thread, nullptr);

    pthread_mutex_lock(&emu_mutex);
    emu_initialized = false;
    pthread_mutex_unlock(&emu_mutex);

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
        gamepad_context->bindings.load_bindings(argv[1]);
        gamepad_context->bindings.load_scripts(argv[1], lua_context);
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

#endif