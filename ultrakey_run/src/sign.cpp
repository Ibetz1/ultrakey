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

#define BLOCK_SIZE 16384 // 16KB buffer

void sha256_hwid_key(const char *hwid, uint8_t *key_out) {
    SHA256((const uint8_t *)hwid, strlen(hwid), key_out);
}


uint8_t *encrypt_buffer_in_place(uint8_t *buffer, size_t *length, const char *hwid) {
    if (!buffer || !length || *length == 0) return NULL;

    uint8_t key[32], iv[16];
    sha256_hwid_key(hwid, key);
    RAND_bytes(iv, sizeof(iv));

    // Prepare output buffer: IV + encrypted data (same length as input, plus IV)
    size_t original_len = *length;
    size_t max_out = 16 + original_len + 16; // 16 for IV + possible overhead
    uint8_t *out_buf = (uint8_t *)realloc(buffer, max_out);
    if (!out_buf) return NULL;

    // Move original data forward to make room for IV at the start
    memmove(out_buf + 16, out_buf, original_len);
    memcpy(out_buf, iv, 16); // write IV at the beginning

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_EncryptInit_ex(ctx, EVP_aes_256_ctr(), NULL, key, iv);

    size_t buffer_offset = 16;
    int chunk_len;
    size_t total_encrypted = 0;

    for (size_t i = 0; i < original_len; i += BLOCK_SIZE) {
        size_t block = (i + BLOCK_SIZE <= original_len) ? BLOCK_SIZE : (original_len - i);
        EVP_EncryptUpdate(ctx, out_buf + buffer_offset, &chunk_len, out_buf + 16 + i, block);
        buffer_offset += chunk_len;
        total_encrypted += chunk_len;
    }

    EVP_EncryptFinal_ex(ctx, out_buf + buffer_offset, &chunk_len);
    buffer_offset += chunk_len;
    total_encrypted += chunk_len;

    EVP_CIPHER_CTX_free(ctx);

    *length = 16 + total_encrypted;
    return out_buf;
}

uint8_t *decrypt_buffer_in_place(uint8_t *buffer, size_t *length, const char *hwid) {
    if (!buffer || !length || *length <= 16) return NULL;

    uint8_t key[32], iv[16];
    sha256_hwid_key(hwid, key);
    memcpy(iv, buffer, 16);

    size_t encrypted_len = *length - 16;

    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    EVP_DecryptInit_ex(ctx, EVP_aes_256_ctr(), NULL, key, iv);

    uint8_t *out_buf = (uint8_t *)malloc(encrypted_len);
    if (!out_buf) {
        EVP_CIPHER_CTX_free(ctx);
        return NULL;
    }

    int chunk_len;
    size_t total = 0;

    for (size_t i = 0; i < encrypted_len; i += BLOCK_SIZE) {
        size_t block = (i + BLOCK_SIZE <= encrypted_len) ? BLOCK_SIZE : (encrypted_len - i);
        EVP_DecryptUpdate(ctx, out_buf + i, &chunk_len, buffer + 16 + i, block);
        total += chunk_len;
    }

    EVP_DecryptFinal_ex(ctx, out_buf + total, &chunk_len);
    total += chunk_len;

    EVP_CIPHER_CTX_free(ctx);
    free(buffer);

    *length = total;
    return out_buf;
}