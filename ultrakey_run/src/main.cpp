#include "main.hpp"

#define CMDLINE_BUFFER_SIZE 2048

// Returns pointer to static buffer or NULL if not enough args or overflow
char* build_command_line_from_args(int argc, char* argv[], int startIndex) {
    static char cmdline[CMDLINE_BUFFER_SIZE];
    size_t offset = 0;

    if (argc <= startIndex) {
        return nullptr;
    }

    // Add argv[0] if startIndex > 0
    if (startIndex > 0 && argv[0]) {
        const char* arg0 = argv[0];
        int needsQuotes = (strchr(arg0, ' ') != NULL || strchr(arg0, '\t') != NULL);

        if (needsQuotes && offset < CMDLINE_BUFFER_SIZE - 1) {
            cmdline[offset++] = '"';
        }

        while (*arg0 && offset < CMDLINE_BUFFER_SIZE - 1) {
            cmdline[offset++] = *arg0++;
        }

        if (needsQuotes && offset < CMDLINE_BUFFER_SIZE - 1) {
            cmdline[offset++] = '"';
        }

        cmdline[offset++] = ' ';
    }

    for (int i = startIndex; i < argc; ++i) {
        const char* arg = argv[i];

        if (i > startIndex && offset < CMDLINE_BUFFER_SIZE - 1) {
            cmdline[offset++] = ' ';
        }

        int needsQuotes = (strchr(arg, ' ') != NULL || strchr(arg, '\t') != NULL);
        if (needsQuotes && offset < CMDLINE_BUFFER_SIZE - 1) {
            cmdline[offset++] = '"';
        }

        while (*arg && offset < CMDLINE_BUFFER_SIZE - 1) {
            cmdline[offset++] = *arg++;
        }

        if (needsQuotes && offset < CMDLINE_BUFFER_SIZE - 1) {
            cmdline[offset++] = '"';
        }
    }

    if (offset >= CMDLINE_BUFFER_SIZE - 1) {
        return nullptr;
    }

    cmdline[offset] = '\0';
    return cmdline;
}

bool runPEFromTempBytes(const uint8_t* exeData, size_t exeSize, char* args = nullptr) {
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

    char cwd[MAX_PATH];
    GetCurrentDirectoryA(MAX_PATH, cwd);

    STARTUPINFO si = { sizeof(si) };
    PROCESS_INFORMATION pi;
    if (!CreateProcess(
        tempFile,
        args,
        nullptr,
        nullptr,
        FALSE,
        0,
        nullptr,
        cwd,
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

    LOGI("process created %i", pi.dwProcessId);

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

    const char* base_name = last_slash ? last_slash + 1 : path;

    LOGI("got basename %s\n", base_name);

    return base_name;
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

void run_bytes(uint8_t* bytes, size_t size, const char* target, char* args = nullptr) {
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
        
        runPEFromTempBytes(extracted_1, extracted_len_1, args);
        printf("\n");

        free(extracted_1);
        return;
    }

    if (right_hash == target_hash) {
        free(extracted_1);
        runPEFromTempBytes(extracted_2, extracted_len_2, args);
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

int main(int argc, char* argv[]) {
    char packed_binary[sizeof(mdcr_table_dfipt)] = { 0 };
    obf_decrypt(packed_binary, mdcr_table_dfipt, sizeof(mdcr_table_dfipt) - 1, 0xA5);

    char ui_binary[sizeof(mdcr_table_dfopt)] = { 0 };
    obf_decrypt(ui_binary, mdcr_table_dfopt, sizeof(mdcr_table_dfopt) - 1, 0x4A);

    LOGI("ultrakey runner starting");

    if (argc > 3 && strcmp(argv[1], STR("pack")) == 0) {
        if (remove(STR("license.key")) == 0) {
            LOGI("removed keyfile");
        }

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
    FILE* key_file = fopen(STR("license.key"), "rb");
    
    if (!key_file) {
        key_file = fopen(STR("license.key"), "wb+");
        if (!key_file) {
            THROW("file system failed");
        }
        fwrite(STR("key"), 3, 1, key_file);

        LOGI("Creating license");
        out_bin = encrypt_buffer_in_place(out_bin, &out_len, hwid);

        LOGI("exporting license");
        export_binary(packed_binary, out_bin, out_len);
    }

    fclose(key_file);

    out_bin = decrypt_buffer_in_place(out_bin, &out_len, hwid);
    LOGI("running executables");
    
    if (argc >= 2) {
        char* args = build_command_line_from_args(argc, argv, 2);
        run_bytes(out_bin, out_len, argv[1], args);
        free(out_bin);
        return 0;
    }

    char* args = build_command_line_from_args(argc, argv, 1);
    run_bytes(out_bin, out_len, ui_binary, args);
    return 0;
}