#include "main.hpp"

std::unordered_map<std::string, VirtualKey> key_ref_enum = {
    { "None" , VKEY_None },
    { "ESCAPE" , VKEY_ESCAPE },
    { "N1" , VKEY_1 },
    { "N2" , VKEY_2 },
    { "N3" , VKEY_3 },
    { "N4" , VKEY_4 },
    { "N5" , VKEY_5 },
    { "N6" , VKEY_6 },
    { "N7" , VKEY_7 },
    { "N8" , VKEY_8 },
    { "N9" , VKEY_9 },
    { "N0" , VKEY_0 },
    { "MINUS" , VKEY_MINUS },
    { "EQUALS" , VKEY_EQUALS },
    { "BACKSPACE" , VKEY_BACKSPACE },
    { "TAB" , VKEY_TAB },
    { "Q" , VKEY_Q },
    { "W" , VKEY_W },
    { "E" , VKEY_E },
    { "R" , VKEY_R },
    { "T" , VKEY_T },
    { "Y" , VKEY_Y },
    { "U" , VKEY_U },
    { "I" , VKEY_I },
    { "O" , VKEY_O },
    { "P" , VKEY_P },
    { "LEFT_BRACKET" , VKEY_LEFT_BRACKET },
    { "RIGHT_BRACKET" , VKEY_RIGHT_BRACKET },
    { "ENTER" , VKEY_ENTER },
    { "LEFT_CTRL" , VKEY_LEFT_CTRL },
    { "A" , VKEY_A },
    { "S" , VKEY_S },
    { "D" , VKEY_D },
    { "F" , VKEY_F },
    { "G" , VKEY_G },
    { "H" , VKEY_H },
    { "J" , VKEY_J },
    { "K" , VKEY_K },
    { "L" , VKEY_L },
    { "SEMICOLON" , VKEY_SEMICOLON },
    { "APOSTROPHE" , VKEY_APOSTROPHE },
    { "GRAVE" , VKEY_GRAVE },
    { "LEFT_SHIFT" , VKEY_LEFT_SHIFT },
    { "BACKSLASH" , VKEY_BACKSLASH },
    { "Z" , VKEY_Z },
    { "X" , VKEY_X },
    { "C" , VKEY_C },
    { "V" , VKEY_V },
    { "B" , VKEY_B },
    { "N" , VKEY_N },
    { "M" , VKEY_M },
    { "COMMA" , VKEY_COMMA },
    { "PERIOD" , VKEY_PERIOD },
    { "SLASH" , VKEY_SLASH },
    { "RIGHT_SHIFT" , VKEY_RIGHT_SHIFT },
    { "KP_MULTIPLY" , VKEY_KP_MULTIPLY },
    { "LEFT_ALT" , VKEY_LEFT_ALT },
    { "SPACE" , VKEY_SPACE },
    { "CAPS_LOCK" , VKEY_CAPS_LOCK },
    { "F1" , VKEY_F1 },
    { "F2" , VKEY_F2 },
    { "F3" , VKEY_F3 },
    { "F4" , VKEY_F4 },
    { "F5" , VKEY_F5 },
    { "F6" , VKEY_F6 },
    { "F7" , VKEY_F7 },
    { "F8" , VKEY_F8 },
    { "F9" , VKEY_F9 },
    { "F10" , VKEY_F10 },
    { "NUM_LOCK" , VKEY_NUM_LOCK },
    { "SCROLL_LOCK" , VKEY_SCROLL_LOCK },
    { "KP_7" , VKEY_KP_7 },
    { "KP_8" , VKEY_KP_8 },
    { "KP_9" , VKEY_KP_9 },
    { "KP_MINUS" , VKEY_KP_MINUS },
    { "KP_4" , VKEY_KP_4 },
    { "KP_5" , VKEY_KP_5 },
    { "KP_6" , VKEY_KP_6 },
    { "KP_PLUS" , VKEY_KP_PLUS },
    { "KP_1" , VKEY_KP_1 },
    { "KP_2" , VKEY_KP_2 },
    { "KP_3" , VKEY_KP_3 },
    { "KP_0" , VKEY_KP_0 },
    { "KP_DECIMAL" , VKEY_KP_DECIMAL },
    { "KP_ENTER" , VKEY_KP_ENTER },
    { "RIGHT_CTRL" , VKEY_RIGHT_CTRL },
    { "KP_DIVIDE" , VKEY_KP_DIVIDE },
    { "RIGHT_ALT" , VKEY_RIGHT_ALT },
    { "HOME" , VKEY_HOME },
    { "UP" , VKEY_UP },
    { "PAGE_UP" , VKEY_PAGE_UP },
    { "LEFT" , VKEY_LEFT },
    { "RIGHT" , VKEY_RIGHT },
    { "END" , VKEY_END },
    { "DOWN" , VKEY_DOWN },
    { "PAGE_DOWN" , VKEY_PAGE_DOWN },
    { "INSERT" , VKEY_INSERT },
    { "DELETE" , VKEY_DELETE },
    { "LEFT_WINDOWS" , VKEY_LEFT_WINDOWS },
    { "RIGHT_WINDOWS" , VKEY_RIGHT_WINDOWS },
    { "APPLICATION" , VKEY_APPLICATION },
    { "MOUSE_LB" , VKEY_MOUSE_LB },
    { "MOUSE_RB" , VKEY_MOUSE_RB },
    { "MOUSE_MB" , VKEY_MOUSE_MB },
    { "MOUSE_MW" , VKEY_MOUSE_MW },
    { "MOUSE", VKEY_MOUSE },
    { "KEYBOARD", VKEY_KEYBOARD },
};

std::unordered_map<std::string, ButtonCode> pad_ref_enum = {
    { "GAMEPAD_DPAD_UP" , BCODE_GAMEPAD_DPAD_UP },
    { "GAMEPAD_DPAD_DOWN" , BCODE_GAMEPAD_DPAD_DOWN },
    { "GAMEPAD_DPAD_LEFT" , BCODE_GAMEPAD_DPAD_LEFT },
    { "GAMEPAD_DPAD_RIGHT" , BCODE_GAMEPAD_DPAD_RIGHT },
    { "GAMEPAD_START" , BCODE_GAMEPAD_START },
    { "GAMEPAD_BACK" , BCODE_GAMEPAD_BACK },
    { "GAMEPAD_LEFT_THUMB" , BCODE_GAMEPAD_LEFT_THUMB },
    { "GAMEPAD_RIGHT_THUMB" , BCODE_GAMEPAD_RIGHT_THUMB },
    { "GAMEPAD_LEFT_SHOULDER" , BCODE_GAMEPAD_LEFT_SHOULDER },
    { "GAMEPAD_RIGHT_SHOULDER" , BCODE_GAMEPAD_RIGHT_SHOULDER },
    { "GAMEPAD_GUIDE" , BCODE_GAMEPAD_GUIDE },
    { "GAMEPAD_A" , BCODE_GAMEPAD_A },
    { "GAMEPAD_B" , BCODE_GAMEPAD_B },
    { "GAMEPAD_X" , BCODE_GAMEPAD_X },
    { "GAMEPAD_Y" , BCODE_GAMEPAD_Y }
};

void precise_wait(double milliseconds) {
    auto start = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double, std::milli>(milliseconds);
    while (std::chrono::high_resolution_clock::now() - start < duration);
}

int LuaBindings::lua_key_down(lua_State* L) {
    int key_code = luaL_checkinteger(L, 1);

    bool key_down = itf->key_down((VirtualKey) key_code);

    lua_pushboolean(L, key_down);
    return 1;
}

int LuaBindings::lua_binding_down(lua_State* L) {
    size_t size;
    const char* binding = luaL_checklstring(L, 1, &size);

    bool key_down = itf->flag_active(binding);

    lua_pushboolean(L, key_down);
    return 1;
}

int LuaBindings::lua_get_value(lua_State* L) {
    size_t size;
    const char* binding = luaL_checklstring(L, 1, &size);

    int val = itf->get_value(binding);

    lua_pushinteger(L, val);
    return 1;
}

int LuaBindings::lua_binding_key(lua_State* L) {
    size_t size;
    const char* binding = luaL_checklstring(L, 1, &size);

    for (auto& [key, val] : itf->tagged_bindings) {
        if (val == std::string(binding)) {
            lua_pushinteger(L, key);
            return 1;
        }
    }

    return 0;
}

int LuaBindings::lua_press_key(lua_State* L) {
    int key_code = luaL_checkinteger(L, 1);

    itf->push_keystroke((VirtualKey) key_code, INTERCEPTION_KEY_DOWN);

    return 0;
}

int LuaBindings::lua_press_button(lua_State* L) {
    int key_code = luaL_checkinteger(L, 1);

    remapper->press_button((ButtonCode) key_code);

    return 0;
}

int LuaBindings::lua_release_key(lua_State* L) {
    int key_code = luaL_checkinteger(L, 1);

    itf->push_keystroke((VirtualKey) key_code, INTERCEPTION_KEY_UP);

    return 0;
}

int LuaBindings::lua_move_cursor(lua_State* L) {
    int dx = luaL_checkinteger(L, 1);
    int dy = luaL_checkinteger(L, 2);

    itf->move_cursor(dx, dy, INTERCEPTION_MOUSE_MOVE_RELATIVE);

    return 0;
}

int LuaBindings::lua_wait(lua_State* L) {
    float wait_time_ms = luaL_checknumber(L, 1);

    precise_wait(wait_time_ms);

    return 0;
}

int LuaBindings::lua_block_key(lua_State* L) {
    int binding = luaL_checkinteger(L, 1);
    if (!lua_isboolean(L, 2)) {
        return luaL_error(L, "Unvalid type, expecing boolean");
    }

    bool state = lua_toboolean(L, 2);

    itf->block((VirtualKey) binding, state);

    return 0;
}

int LuaBindings::lua_toggle_controller(lua_State* L) {
    if (!lua_isboolean(L, 1)) {
        return luaL_error(L, "Unvalid type, expecing boolean");
    }

    bool state = lua_toboolean(L, 1);

    remapper->toggle_controller(state);

    return 0;
}

int LuaBindings::lua_stick_offset(lua_State* L) {
    float dx = luaL_checknumber(L, 1);
    float dy = luaL_checknumber(L, 2);

    remapper->analog_offset.dx = dx;
    remapper->analog_offset.dy = dy;

    return 0;
}

int LuaBindings::lua_aim_offset(lua_State* L) {
    float dx = luaL_checknumber(L, 1);
    float dy = luaL_checknumber(L, 2);

    remapper->aim_offset.dx = dx;
    remapper->aim_offset.dy = dy;

    return 0;
}

void LuaBindings::push_enums(lua_State* L) {
    lua_newtable(L);

    for (auto& [name, binding] : key_ref_enum) {
        lua_pushinteger(L, (int) binding);
        lua_setfield(L, -2, name.c_str());
    }

    lua_setglobal(L, "Key");
    lua_newtable(L);

    for (auto& [name, binding] : pad_ref_enum) {
        lua_pushinteger(L, (int) binding);
        lua_setfield(L, -2, name.c_str());
    }

    lua_setglobal(L, "Button");
}

void LuaBindings::register_functions(lua_State* L) {
    lua_register(L, "KeyDown", lua_key_down);
    lua_register(L, "PressKey", lua_press_key);
    lua_register(L, "PressButton", lua_press_button);
    lua_register(L, "BlockKey", lua_block_key);
    lua_register(L, "ReleaseKey", lua_release_key);
    lua_register(L, "MoveCursor", lua_move_cursor);
    lua_register(L, "Wait", lua_wait);
    lua_register(L, "Event", lua_binding_down);
    lua_register(L, "Value", lua_get_value);
    lua_register(L, "EventBinding", lua_binding_key);
    lua_register(L, "MoveLStick", lua_stick_offset);
    lua_register(L, "MoveRStick", lua_aim_offset);
    lua_register(L, "ToggleController", lua_toggle_controller);
}

void LuaBindings::bind_input_interface(InputInterface* input_itf) {
    itf = input_itf;
    LOGI("LUA: bound input interface");
}

void LuaBindings::bind_remapper(InputRemapper* itf) {
    remapper = itf;
    LOGI("LUA: bound remapper interface");
}

InputInterface* LuaBindings::itf = nullptr;
InputRemapper* LuaBindings::remapper = nullptr;

LuaScript::LuaScript(const char* file) {
    L = luaL_newstate();
   luaL_openlibs(L);

    LuaBindings::register_functions(L);
    LuaBindings::push_enums(L);

    if (luaL_dofile(L, file) != LUA_OK) {
        lua_close(L);
        LOGE("LUA error: %s\n", lua_tostring(L, -1));
    }
}

LuaScript::~LuaScript() {
    lua_close(L);
}

void LuaScript::update() const {
    lua_getglobal(L, "main");
    lua_pushnil(L);

    if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
        lua_pop(L, 1);
        THROW("LUA error: %s\n", lua_tostring(L, -1));
    }
}

LuaEnvironment::LuaEnvironment(const char* path) : script(LuaScript(path)) {
    mutex = pthread_mutex_init(&mutex, nullptr);
    LOGI("created lua environment");
}

LuaEnvironment::~LuaEnvironment() {
    pthread_mutex_destroy(&mutex);
    LOGI("destroyed lua environment");
}

void* LuaEnvironment::main(void* arg) {
    LuaEnvironment* env = (LuaEnvironment*) arg;

    while (env->running) {
        // // pthread_mutex_lock(&LuaBindings::itf->mutex);
        // // pthread_mutex_lock(&env->mutex);
        
        if (LuaBindings::itf->toggle_intercept) {
            env->script.update();
        }

        // // pthread_mutex_lock(&env->mutex);
        // // pthread_mutex_lock(&LuaBindings::itf->mutex);

        Sleep(5);
    }

    return nullptr;
}

void LuaEnvironment::start() {
    running = true;

    if (pthread_create(&thread, NULL, main, this) != 0) {
        THROW("failed to start thread");
    } else {
        LOGI("lua interface started");
    }

    pthread_detach(thread);
}

void LuaEnvironment::stop() {
    running = false;
    pthread_join(thread, nullptr);
}