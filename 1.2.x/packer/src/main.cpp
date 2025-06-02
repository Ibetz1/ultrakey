#include <windows.h>
#include <iphlpapi.h>
#include <shlobj.h>
#include <stdio.h>
#include <stdint.h>

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "shell32.lib")

#define CACHE_FILE "cache.txt"

const uint8_t STATIC_KEY[] = { 0xA5, 0x6C, 0x3E, 0xB1, 0x19, 0xDE, 0x87, 0x44 };

bool patch_version_info(const char* exe_path, const char* new_name) {
    DWORD handle = 0;
    DWORD size = GetFileVersionInfoSizeA(exe_path, &handle);
    if (size == 0) return false;

    void* data = malloc(size);
    if (!data) return false;

    if (!GetFileVersionInfoA(exe_path, 0, size, data)) {
        free(data);
        return false;
    }

    // Get translation info
    struct LANGANDCODEPAGE {
        WORD wLanguage;
        WORD wCodePage;
    } *lpTranslate;

    UINT cbTranslate = 0;
    if (!VerQueryValueA(data, "\\VarFileInfo\\Translation", (LPVOID*)&lpTranslate, &cbTranslate) || cbTranslate == 0) {
        free(data);
        return false;
    }

    char subblock[64];
    char* value = NULL;
    UINT len;

    HANDLE hUpdate = BeginUpdateResourceA(exe_path, FALSE);
    if (!hUpdate) {
        free(data);
        return false;
    }

    for (UINT i = 0; i < cbTranslate / sizeof(struct LANGANDCODEPAGE); ++i) {
        sprintf(subblock, "\\StringFileInfo\\%04x%04x\\FileDescription", lpTranslate[i].wLanguage, lpTranslate[i].wCodePage);
        UpdateResourceA(hUpdate, (LPCSTR) RT_STRING, subblock, MAKELANGID(lpTranslate[i].wLanguage, lpTranslate[i].wCodePage),
                        (LPVOID)new_name, (DWORD)(strlen(new_name) + 1));

        sprintf(subblock, "\\StringFileInfo\\%04x%04x\\OriginalFilename", lpTranslate[i].wLanguage, lpTranslate[i].wCodePage);
        UpdateResourceA(hUpdate, (LPCSTR) RT_STRING, subblock, MAKELANGID(lpTranslate[i].wLanguage, lpTranslate[i].wCodePage),
                        (LPVOID)new_name, (DWORD)(strlen(new_name) + 1));
    }

    EndUpdateResourceA(hUpdate, FALSE);
    free(data);
    return true;
}

void xor_encrypt(const char* input, char* output_hex, size_t key_len) {
    size_t len = strlen(input);
    for (size_t i = 0; i < len; ++i) {
        uint8_t encrypted = input[i] ^ STATIC_KEY[i % key_len];
        sprintf(output_hex + (i * 2), "%02X", encrypted);
    }
    output_hex[len * 2] = '\0';
}

void xor_decrypt(const char* input_hex, char* output, size_t key_len) {
    size_t len = strlen(input_hex) / 2;
    for (size_t i = 0; i < len; ++i) {
        char byte_str[3] = { input_hex[i * 2], input_hex[i * 2 + 1], '\0' };
        uint8_t byte = (uint8_t)strtoul(byte_str, NULL, 16);
        output[i] = byte ^ STATIC_KEY[i % key_len];
    }
    output[len] = '\0';
}

uint32_t hash(const char* str, const uint8_t* mac) {
    uint32_t h = 5381;
    while (*str) h = ((h << 5) + h) + *str++;
    for (int i = 0; i < 6; ++i) h = ((h << 5) + h) + mac[i];
    return h;
}

bool get_mac_address(uint8_t* mac_out) {
    IP_ADAPTER_INFO adapterInfo[16];
    DWORD buflen = sizeof(adapterInfo);
    if (GetAdaptersInfo(adapterInfo, &buflen) == NO_ERROR) {
        memcpy(mac_out, adapterInfo[0].Address, 6);
        return true;
    }
    return false;
}

void generate_bin_name(char* out, size_t len) {
    const char* static_name = "ultrakey";
    uint8_t mac[6] = {};
    if (!get_mac_address(mac)) {
        strncpy(out, "ultrakey_fallback", len);
        return;
    }

    uint32_t h = hash(static_name, mac);
    snprintf(out, len, "%08X.exe", h);
}

void cache_temp(const char* bin_path) {
    char encrypted[MAX_PATH * 2];
    xor_encrypt(bin_path, encrypted, sizeof(STATIC_KEY));

    FILE* f = fopen(CACHE_FILE, "w");
    if (f) {
        fprintf(f, "%s", encrypted);
        fclose(f);
    }
}

void clean_temp_cache() {
    char encrypted[MAX_PATH * 2];
    FILE* f = fopen(CACHE_FILE, "r");
    if (f) {
        if (fgets(encrypted, sizeof(encrypted), f)) {
            char decrypted[MAX_PATH];
            xor_decrypt(encrypted, decrypted, sizeof(STATIC_KEY));
            DeleteFileA(decrypted);
        }
        fclose(f);
        DeleteFileA(CACHE_FILE);
    }
}

bool copy_binary(const char* src, const char* dest) {
    return CopyFileA(src, dest, FALSE);
}

void run_binary(const char* bin_path, size_t len) {
    char cwd[MAX_PATH];
    GetCurrentDirectoryA(MAX_PATH, cwd);

    char bin_name[64];
    generate_bin_name(bin_name, sizeof(bin_name));

    char full_cwd_bin[MAX_PATH];
    snprintf(full_cwd_bin, MAX_PATH, "%s\\%s", cwd, bin_name);

    clean_temp_cache();

    if (!copy_binary(bin_path, full_cwd_bin)) {
        printf("Failed to copy binary to CWD.\n");
        return;
    }

    if (!patch_version_info(full_cwd_bin, bin_name)) {
        printf("Warning: failed to update version info.\n");
    }

    cache_temp(full_cwd_bin);

    ShellExecuteA(NULL, "open", full_cwd_bin, NULL, NULL, SW_SHOW);
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        const char default_name[] = "packed.bin";
        run_binary(default_name, sizeof(default_name));
        return 0;
    }

    run_binary(argv[1], strlen(argv[1]));
    return 0;
}

/*
    compress entire compilation
    decompress compilation into temp dir
    run decompressed version
*/