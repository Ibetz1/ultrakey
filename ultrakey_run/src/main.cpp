#include "main.hpp"

bool runPEFromTempBytes(const uint8_t* exeData, size_t exeSize) {
    TCHAR tempPath[MAX_PATH];
    GetTempPath(MAX_PATH, tempPath);

    TCHAR tempFile[MAX_PATH];
    GetTempFileName(tempPath, TEXT("PE_"), 0, tempFile);

    HANDLE hFile = CreateFile(
        tempFile,
        GENERIC_WRITE | GENERIC_READ,
        0,
        nullptr,
        CREATE_ALWAYS,
        FILE_ATTRIBUTE_TEMPORARY,
        nullptr
    );

    if (hFile == INVALID_HANDLE_VALUE) {
        THROW("Failed to create temp file. Error: ", GetLastError());
    }

    DWORD written;
    if (!WriteFile(hFile, exeData, (DWORD)exeSize, &written, nullptr)) {
        THROW("Write failed. Error: ", GetLastError());
        CloseHandle(hFile);
    }

    FlushFileBuffers(hFile);
    CloseHandle(hFile);

    STARTUPINFO si = { sizeof(si) };
    PROCESS_INFORMATION pi;
    if (!CreateProcess(
        tempFile,      
        nullptr,
        nullptr,       
        nullptr,       
        FALSE,         
        0,
        nullptr,
        nullptr,       
        &si,
        &pi
    )) {
        THROW("Process launch failed. Error: ", GetLastError());
    }

    HANDLE job = CreateJobObject(nullptr, nullptr);
    if (job) {
        JOBOBJECT_EXTENDED_LIMIT_INFORMATION jeli = {};
        jeli.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
        SetInformationJobObject(job, JobObjectExtendedLimitInformation, &jeli, sizeof(jeli));
        AssignProcessToJobObject(job, pi.hProcess);
    }

    LOGI("process created");

    WaitForSingleObject(pi.hProcess, INFINITE);

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    DeleteFile(tempFile);

    LOGI("runner finished");
    return true;
}

uint16_t u16_string_hash(const char* str) {
    uint32_t hash = 5381;
    while (*str) {
        hash = ((hash << 5) + hash) ^ (uint8_t)(*str++);
    }

    return (uint16_t)((hash >> 16) ^ (hash & 0xFFFF));
}

const char* get_basename(const char* path) {
    const char* slash1 = strrchr(path, '/');
    const char* slash2 = strrchr(path, '\\');
    const char* last_slash = slash1 > slash2 ? slash1 : slash2;

    return last_slash ? last_slash + 1 : path;
}

void sign_executables(const char* out_path, const char* p1, const char* p2) {
    size_t size1;
    uint8_t* bytes1 = import_binary(p1, &size1);

    size_t size2;
    uint8_t* bytes2 = import_binary(p2, &size2);

    uint16_t p1_hash = u16_string_hash(get_basename(p1));
    uint16_t p2_hash = u16_string_hash(get_basename(p2));

    if (p1_hash == p2_hash) {
        THROW("hash collision is file paths");
    }

    LOGI("%i %s %i %s\n", p1_hash, get_basename(p1), p2_hash, get_basename(p2));

    uint32_t tags;
    tags = ((uint32_t)p1_hash << 16) | p2_hash;

    size_t merged_len;
    uint8_t* merged = merge_binaries(bytes1, bytes2, size1, size2, &merged_len, tags);

    export_binary(out_path, merged, merged_len);
    
    free(bytes1);
    free(bytes2);
    free(merged);
}

void run_bytes(uint8_t* bytes, size_t size, const char* target) {
    uint16_t target_hash = u16_string_hash(get_basename(target));

    uint8_t* extracted_1;
    uint8_t* extracted_2;
    size_t extracted_len_1;
    size_t extracted_len_2;
    uint32_t sig = extract_binaries(bytes, &extracted_1, &extracted_2, &extracted_len_1, &extracted_len_2);

    uint16_t left_hash = (uint16_t) (sig >> 16) & 0xFFFF;
    uint16_t right_hash  = (uint16_t) (sig) & 0xFFFF;

    if (left_hash == target_hash) {
        free(extracted_2);
        
        runPEFromTempBytes(extracted_1, extracted_len_1);
        printf("\n");

        free(extracted_1);
        return;
    }

    if (right_hash == target_hash) {
        free(extracted_1);
        runPEFromTempBytes(extracted_2, extracted_len_2);
        printf("\n");

        free(extracted_2);
        return;
    }

    THROW("invalid embedded signature %04x %04x %04x", left_hash, right_hash, target_hash);
}

void invalid_args() {
    printf(STR("valid params:\n"));
    printf(STR("pack <binA> <binB> <packed>\n"));
    printf(STR("run <packed> <sig>\n"));
    THROW("invalid arguments");
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

int main(int argc, char* argv[]) {
    char packed_binary[sizeof(mdcr_table_dfipt)] = { 0 };
    obf_decrypt(packed_binary, mdcr_table_dfipt, sizeof(mdcr_table_dfipt) - 1, 0xA5);

    char ui_binary[sizeof(mdcr_table_dfopt)] = { 0 };
    obf_decrypt(ui_binary, mdcr_table_dfopt, sizeof(mdcr_table_dfopt) - 1, 0x4A);

    LOGI("ultrakey runner starting");

    if (argc > 3 && strcmp(argv[1], STR("pack")) == 0) {
        sign_executables(packed_binary, argv[2], argv[3]);
        return 0;
    }

    LOGI("finding packer");

    FILE* temp = fopen(packed_binary, "r");
    if (temp == nullptr) {
        THROW("cannot find packed binaries");
    } else {
        fclose(temp);
    }

    size_t out_len;
    uint8_t* out_bin = import_binary(packed_binary, &out_len);

    char hwid[65] = { 0 };
    get_hardware_hash(hwid);
    FILE* key_file = fopen(STR("liscense.key"), "rb");
    
    if (!key_file) {
        key_file = fopen(STR("liscense.key"), "wb+");
        if (!key_file) {
            THROW("file system failed");
        }
        fwrite(STR("key"), 3, 1, key_file);

        LOGI("Creating Liscense");
        out_bin = encrypt_buffer_in_place(out_bin, &out_len, hwid);

        LOGI("exporting liscense");
        export_binary(packed_binary, out_bin, out_len);
    }

    fclose(key_file);

    out_bin = decrypt_buffer_in_place(out_bin, &out_len, hwid);
    LOGI("running executables");

    if (argc == 2) {
        run_bytes(out_bin, out_len, argv[1]);
        free(out_bin);
        return 0;
    }

    LOGI("passed EMU");
    run_bytes(out_bin, out_len, ui_binary);
    return 0;
}