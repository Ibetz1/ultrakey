#ifndef _LUA_BINDINGS_HPP
#define _LUA_BINDINGS_HPP

struct InputRemapper;

struct LuaBindings {
    static InputInterface* itf;
    static InputRemapper* remapper;

    static int lua_key_down(lua_State* L);
    
    static int lua_binding_down(lua_State* L);

    static int lua_binding_key(lua_State* L);

    static int lua_get_value(lua_State* L);

    static int lua_press_key(lua_State* L);

    static int lua_press_button(lua_State* L);

    static int lua_block_key(lua_State* L);
    
    static int lua_release_key(lua_State* L);
    
    static int lua_move_cursor(lua_State* L);

    static int lua_stick_offset(lua_State* L);

    static int lua_aim_offset(lua_State* L);

    static int lua_wait(lua_State* L);

    static void push_enums(lua_State* L);
    
    static void register_functions(lua_State* L);

    static void bind_input_interface(InputInterface* itf);

    static void bind_remapper(InputRemapper* rmp);
};

struct LuaScript {
    lua_State* L = nullptr;
    lua_State* coro = nullptr;
    bool is_running = false;    
    
    LuaScript(const char* file);
    ~LuaScript();
    void update() const;
    void resume_coroutines();
};

struct LuaEnvironment {
    LuaScript script;
    pthread_t thread = 0;
    pthread_mutex_t mutex = 0;
    bool running = false;

    LuaEnvironment(const char* path);

    ~LuaEnvironment();

    static void* main(void*);

    void start();

    void stop();
};

#endif