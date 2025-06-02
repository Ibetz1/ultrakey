#include "stdio.h"
#include <windows.h>
#include <stdint.h>

static uint64_t get_time_us() {
    LARGE_INTEGER freq, counter;
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&counter);
    return (uint64_t)(1e6 * counter.QuadPart / freq.QuadPart);
}

int main() {
    printf("hello world\n");

    while (true) {}

    return 0;
}