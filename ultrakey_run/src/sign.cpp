#include "main.hpp"

void sha256_hex(const char* input, char* output, size_t output_len) {
    HCRYPTPROV hProv = 0;
    HCRYPTHASH hHash = 0;
    BYTE hash[32];
    DWORD hashLen = sizeof(hash);
    output[0] = '\0';

    if (CryptAcquireContext(&hProv, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        if (CryptCreateHash(hProv, CALG_SHA_256, 0, 0, &hHash)) {
            CryptHashData(hHash, (const BYTE*)input, strlen(input), 0);
            if (CryptGetHashParam(hHash, HP_HASHVAL, hash, &hashLen, 0)) {
                for (DWORD i = 0; i < hashLen && (i * 2 + 1) < output_len; ++i) {
                    char tmp[3];
                    sprintf(tmp, "%02x", hash[i]);
                    strcat(output, tmp);
                }
            }
            CryptDestroyHash(hHash);
        }
        CryptReleaseContext(hProv, 0);
    }
}

void get_volume_serial(char* out, size_t len) {
    DWORD serial = 0;
    GetVolumeInformationA("C:\\", NULL, 0, &serial, NULL, NULL, NULL, 0);
    snprintf(out, len, "%08X", serial);
}

void get_cpu_id(char* out, size_t len) {
    int cpuInfo[4] = { 0 };
    __get_cpuid(0, (unsigned int*)&cpuInfo[0], (unsigned int*)&cpuInfo[1], (unsigned int*)&cpuInfo[2], (unsigned int*)&cpuInfo[3]);
    snprintf(out, len, "%08X%08X%08X%08X", cpuInfo[0], cpuInfo[1], cpuInfo[2], cpuInfo[3]);
}

void get_bios_uuid(char* out, size_t len) {
    HKEY hKey;
    out[0] = '\0';
    if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, STR("SOFTWARE\\Microsoft\\Cryptography"), 0, KEY_READ | KEY_WOW64_64KEY, &hKey) == ERROR_SUCCESS) {
        DWORD size = (DWORD)len;
        RegQueryValueExA(hKey, STR("MachineGuid"), NULL, NULL, (LPBYTE)out, &size);
        RegCloseKey(hKey);
    }
}

void get_mac_address(char* out, size_t len) {
    IP_ADAPTER_INFO adapterInfo[16];
    DWORD buflen = sizeof(adapterInfo);
    out[0] = '\0';

    if (GetAdaptersInfo(adapterInfo, &buflen) == NO_ERROR) {
        PIP_ADAPTER_INFO pAdapter = adapterInfo;
        char tmp[4];
        for (UINT i = 0; i < pAdapter->AddressLength && (i * 2 + 1) < len; ++i) {
            sprintf(tmp, "%02X", pAdapter->Address[i]);
            strcat(out, tmp);
        }
    }
}

void get_hardware_hash(char* buf) {
    char volume[32];
    char cpu[64];
    char bios[128];
    char mac[64];
    char combined[MAX_HWID_LEN];

    get_volume_serial(volume, sizeof(volume));
    get_cpu_id(cpu, sizeof(cpu));
    get_bios_uuid(bios, sizeof(bios));
    get_mac_address(mac, sizeof(mac));

    combined[0] = '\0';
    strcat(combined, volume);
    strcat(combined, "|");
    strcat(combined, cpu);
    strcat(combined, "|");
    strcat(combined, bios);
    strcat(combined, "|");
    strcat(combined, mac);

    sha256_hex(combined, buf, 65);
}

void decrypt(char* out, const char* in, size_t len, uint8_t key) {
    for (size_t i = 0; i < len; ++i) {
        out[i] = in[i] ^ key;
    }
    out[len] = '\0';
}