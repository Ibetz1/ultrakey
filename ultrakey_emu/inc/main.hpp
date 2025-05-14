#ifndef _MAIN_HPP
#define _MAIN_HPP

#include <windows.h>
#include <iostream>
#include <math.h>
#include <pthread.h>
#include <vector>
#include <unordered_map>
#include <stdint.h>
#include <sys/stat.h>
#include <string>
#include <thread>

#include "xinput.h"
#include "vigem/Client.h"
#include "interception/interception.h"
#include "json/json.hpp"
#include "lua.hpp"

#define DEBUG_ENABLE 0

using json = nlohmann::json;

constexpr short S16_lim = 0x7FFE - 1;
    
inline float fclampf(float val, float min, float max) {
    return fmaxf(fminf(val, max), min);
}

#define LOGI(fmt, ...) do { printf("I: " fmt "\n", ##__VA_ARGS__); } while (0)
#define LOGE(fmt, ...) do { printf("E: " fmt "\n", ##__VA_ARGS__); } while (0)
#define THROW(fmt, ...) do { LOGE(__FILE__ ":%i " fmt, __LINE__, ##__VA_ARGS__); exit(1); } while (0)

#include "enums.hpp"

struct VecF32 {
    float dx, dy;
};

struct VecInt {
    int dx, dy;
};

struct ToggleBinding {
    int mode;
    VirtualKey binding;
};

#include "input_interface.hpp"
#include "lua_bindings.hpp"
#include "input_remapper.hpp"
#include "gamepad.hpp"
#include "emulator.hpp"
#include "file.hpp"
#include "winsignal.hpp"

#endif