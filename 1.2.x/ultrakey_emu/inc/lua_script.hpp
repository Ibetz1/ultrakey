#ifndef _LUA_SCRIPT_HPP
#define _LUA_SCRIPT_HPP

struct LuaThread {
    lua_State* thread;
    int status;
    uint64_t next_wake_time_ms = 0;
};

struct LuaContext {
    std::vector<LuaThread> scripts;
    GamePad* gamepad;
    lua_State* L;
    bool run = false;

    LuaContext(GamePad* gamepad);

    ~LuaContext();

    void add_script(const char* script_path);

    void tick();
};

#endif