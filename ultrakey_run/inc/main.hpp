#include "iostream"
#include "stdint.h"
#include "memory.h"
#include "string.h"
#include "windows.h"
#include <stdio.h>
#include <iphlpapi.h>
#include <wincrypt.h>
#include <cpuid.h>
#include <stdint.h>
#include <stddef.h>

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "advapi32.lib")

#define MAX_HWID_LEN 512

#include "obf.hpp"

#define LOGI(fmt, ...) do { printf(STR("I: " fmt "\n"), ##__VA_ARGS__); } while (0)
#define LOGE(fmt, ...) do { printf(STR("E: " fmt "\n"), ##__VA_ARGS__); } while (0)
#define THROW(fmt, ...) do { LOGE(__FILE__ ":%i " fmt, __LINE__, ##__VA_ARGS__); exit(1); } while (0)

#include "packer.hpp"
#include "sign.hpp"