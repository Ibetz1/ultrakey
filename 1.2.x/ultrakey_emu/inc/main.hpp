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
#include <unistd.h>
#include <mutex>
#include <queue>
#include <condition_variable>
#include <time.h>
#include <atomic>
#include <inttypes.h>

#include "xinput.h"
#include "vigem/Client.h"
#include "interception/interception.h"
#include "json/json.hpp"
#include "lua.hpp"

#include "enum.hpp"
using json = nlohmann::json;

#define BUILD_DLL true

inline const char* filename_only(const char* path) {
    const char* slash = strrchr(path, '\\');
    if (!slash) slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

#define __FILENAME__ filename_only(__FILE__)

#if BUILD_DLL == true
void throw_message_popup(const char* fmt, ...);

#define LOGI(fmt, ...) do { } while (0)
#define LOGE(fmt, ...) do { } while (0)
#define THROW(fmt, ...) do { throw_message_popup("%s:%i " fmt, __FILENAME__, __LINE__, ##__VA_ARGS__); } while (0)

#else

#define LOGI(fmt, ...) do { printf("I: " fmt "\n", ##__VA_ARGS__); } while (0)
#define LOGE(fmt, ...) do { printf("E: " fmt "\n", ##__VA_ARGS__); } while (0)
#define THROW(fmt, ...) do { LOGE(__FILE__ ":%i " fmt, __LINE__, ##__VA_ARGS__); exit(1); } while (0)

#endif

#define THROW_CRIT(fmt, ...) do { LOGE(__FILE__ ":%i " fmt, __LINE__, ##__VA_ARGS__); exit(1); } while (0)

#define BURN_CYCLE __asm__ __volatile__("pause" ::: "memory")
#define CLK_TIME_INTERVAL_LL 1'000'000'000ULL
#define CLK_TIME_INTERVAL_F 1'000'000'000.f
#define CLK_TIME_CONVERSION(v) ((float) v / CLK_TIME_INTERVAL_F) * 1000.f

inline float fclampf(float val, float min, float max) {
    return fmaxf(fminf(val, max), min);
}

inline int clampi(int val, int min, int max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
}

struct Movement {
    float dx;
    float dy;
    float magnitude;
};

struct LuaContext;

#include "signals.hpp"
#include "vector.hpp"
#include "task_scheduler.hpp"
#include "threaded_queue.hpp"
#include "file.hpp"
#include "mnk_context.hpp"
#include "bindings.hpp"
#include "gamepad.hpp"
#include "lua_script.hpp"


#endif