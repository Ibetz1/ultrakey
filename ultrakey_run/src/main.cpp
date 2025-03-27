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

void run_executables(const char* in_path, const char* target) {
    size_t merged_len;
    uint8_t* merged = import_binary(in_path, &merged_len);
    
    uint16_t target_hash = u16_string_hash(get_basename(target));

    uint8_t* extracted_1;
    uint8_t* extracted_2;
    size_t extracted_len_1;
    size_t extracted_len_2;
    uint32_t sig = extract_binaries(merged, &extracted_1, &extracted_2, &extracted_len_1, &extracted_len_2);
    free(merged);

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

int main(int argc, char* argv[]) {
    char hwid[65] = { 0 };
    get_hardware_hash(hwid);

    if (argc < 2) {
        char decpr_ipt[sizeof(mdcr_table_dfipt)] = { 0 };
        obf_decrypt(decpr_ipt, mdcr_table_dfipt, sizeof(mdcr_table_dfipt) - 1, 0xA5);

        char decpr_out[sizeof(mdcr_table_dfopt)] = { 0 };
        obf_decrypt(decpr_out, mdcr_table_dfopt, sizeof(mdcr_table_dfopt) - 1, 0x4A);

        run_executables(decpr_ipt, decpr_out);
    }

    const char* command = argv[1];

    if (strcmp(command, "pack") == 0) {
        if (argc < 5) {
            invalid_args();
        }

        const char* path_a = argv[2];
        const char* path_b = argv[3];
        const char* out = argv[4];


        sign_executables(out, path_a, path_b);

        return 0;
    }

    if (strcmp(command, "run") == 0) {
        if (argc < 4) {
            invalid_args();
        }

        const char* in = argv[2];
        const char* target = argv[3];

        run_executables(in, target);

        return 0;
    }

    invalid_args();
}