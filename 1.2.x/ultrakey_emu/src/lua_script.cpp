#include "main.hpp"

std::unordered_map<std::string, VirtualKey> key_ref_enum = {
    { "None" , VKEY_NONE },
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

LuaContext* lua_get_context(lua_State* L) {
    lua_getfield(L, LUA_REGISTRYINDEX, "context_ptr");
    LuaContext* context = (LuaContext*) (lua_touserdata(L, -1));
    lua_pop(L, 1);

    if (context == nullptr) {
        THROW("could not find script context");
    }

    return context;
}

int lua_sleep(lua_State* L) {
    int ms = luaL_checkinteger(L, 1);
    lua_pushinteger(L, ms);
    return lua_yield(L, 1);
}

int lua_press_key(lua_State* L) {
    int key_code = luaL_checkinteger(L, 1);
    LuaContext* context = lua_get_context(L);

    context->gamepad->mnk_context->push_key((VirtualKey) key_code, INTERCEPTION_KEY_DOWN);

    return 0;
}

int lua_release_key(lua_State* L) {
    int key_code = luaL_checkinteger(L, 1);
    LuaContext* context = lua_get_context(L);

    context->gamepad->mnk_context->push_key((VirtualKey) key_code, INTERCEPTION_KEY_UP);

    return 0;
}

int lua_key_down(lua_State* L) {
    int key_code = luaL_checkinteger(L, 1);
    LuaContext* context = lua_get_context(L);

    bool key_down = context->gamepad->mnk_context->key_down((VirtualKey) key_code);

    lua_pushboolean(L, key_down);
    return 1;
}

int lua_lerp_mouse(lua_State* L) {
    int dx = luaL_checkinteger(L, 1);
    int dy = luaL_checkinteger(L, 2);
    int time = luaL_checkinteger(L, 3);
    LuaContext* context = lua_get_context(L);

    context->gamepad->mnk_context->move_mouse({(float) dx, (float) dy}, time);
    return 0;
}

int lua_block_key(lua_State* L) {
    int binding = luaL_checkinteger(L, 1);
    LuaContext* context = lua_get_context(L);

    if (!lua_isboolean(L, 2)) {
        return luaL_error(L, "Unvalid type, expecing boolean");
    }

    bool state = lua_toboolean(L, 2);

    context->gamepad->mnk_context->block_key((VirtualKey) binding, state);

    return 0;
}

int lua_binding_down(lua_State* L) {
    size_t size;
    const char* binding = luaL_checklstring(L, 1, &size);
    LuaContext* context = lua_get_context(L);

    bool key_down = context->gamepad->check_flagged_binding(binding);

    lua_pushboolean(L, key_down);
    return 1;
}

int lua_binding_value(lua_State* L) {
    size_t size;
    const char* binding = luaL_checklstring(L, 1, &size);
    LuaContext* context = lua_get_context(L);

    int val = context->gamepad->get_flagged_value(binding);

    lua_pushinteger(L, val);
    return 1;
}

int lua_binding_key(lua_State* L) {
    size_t size;
    const char* binding = luaL_checklstring(L, 1, &size);
    LuaContext* context = lua_get_context(L);

    for (auto& [key, val] : context->gamepad->bindings.tagged_bindings) {
        if (val == std::string(binding)) {
            lua_pushinteger(L, key);
            return 1;
        }
    }

    return 0;
}

void push_enums(lua_State* L) {
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

LuaContext::LuaContext(GamePad* gamepad) :gamepad(gamepad) {
    L = luaL_newstate();
    luaL_openlibs(L);

    lua_pushlightuserdata(L, this);
    lua_setfield(L, LUA_REGISTRYINDEX, "context_ptr");

    push_enums(L);
    lua_register(L, "Wait", lua_sleep);
    lua_register(L, "KeyDown", lua_key_down);
    lua_register(L, "PressKey", lua_press_key);
    lua_register(L, "ReleaseKey", lua_release_key);
    lua_register(L, "BlockKey", lua_block_key);
    lua_register(L, "LerpMouse", lua_lerp_mouse);
    lua_register(L, "BoundValue", lua_binding_value);
    lua_register(L, "BoundKey", lua_binding_key);
    lua_register(L, "BindingDown", lua_binding_down);
}

LuaContext::~LuaContext() {
    lua_close(L);
}

void LuaContext::add_script(const char* script_path) {
    // lua_State* co = lua_newthread(L);

    // if (luaL_loadfile(co, script_path) != LUA_OK) {
    //     THROW("Lua load error: %s", lua_tostring(co, -1));
    //     return;
    // }
    
    // int nres = 0;
    // int status = lua_resume(co, nullptr, 0, &nres);
    
    // uint64_t wake = 0;
    // if (status == LUA_YIELD && nres == 1 && lua_isinteger(co, -1)) {
    //     wake = get_time_ms() + lua_tointeger(co, -1);
    //     lua_pop(co, 1);
    // }
    
    // scripts.push_back({ co, status, wake });
    // LOGI("added script %s", script_path);
    lua_State* co = lua_newthread(L);

    if (luaL_loadfile(co, script_path) != LUA_OK) {
        THROW("Lua load error: %s", lua_tostring(co, -1));
        return;
    }

    // Push thread into list, unstarted
    scripts.push_back({ co, LUA_YIELD, 0 });
    LOGI("added script %s", script_path);
}

void LuaContext::tick() {
    uint64_t now = (uint64_t) CLK_TIME_CONVERSION(get_time_interval());
    for (LuaThread& thread : scripts) {
        if (thread.status != LUA_YIELD)
            continue;

        if (now >= thread.next_wake_time_ms) {
            int nres = 0;
            int status = lua_resume(thread.thread, nullptr, 0, &nres);

            thread.status = status;

            if (status == LUA_YIELD && nres == LUA_YIELD && lua_isinteger(thread.thread, -1)) {
                thread.next_wake_time_ms = now + lua_tointeger(thread.thread, -1);
                lua_pop(thread.thread, 1);
            } else if (status == LUA_OK) {
                // Finished, no more ticks
            } else {
                THROW("lua error: %s", lua_tostring(thread.thread, -1));
                lua_pop(thread.thread, 1);
            }
        }
    }
}