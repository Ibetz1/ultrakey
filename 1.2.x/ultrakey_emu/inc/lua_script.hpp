#ifndef _LUA_SCRIPT_HPP
#define _LUA_SCRIPT_HPP

struct LuaScript {
    lua_State* L;
    TaskScheduler* runner;
    GamePad* gamepad;
    Clock clock;

    LuaScript(const char* path, GamePad* gamepad);
    
    ~LuaScript();
    
    void run_main();
};

#endif