#include <windows.h>
#include <shellapi.h>
#include <iostream>
#include <wincrypt.h>
#include <string>
#include <set>
#include <iostream>
#include <filesystem>
#include <vector>
#include <iomanip>
#include <sstream>

#define DLL_EXPORT extern "C" __declspec(dllexport)

#pragma comment(lib, "advapi32.lib")

bool is_admin() {
    BOOL isAdmin = FALSE;
    PSID adminGroup = NULL;
    SID_IDENTIFIER_AUTHORITY ntAuthority = SECURITY_NT_AUTHORITY;

    if (AllocateAndInitializeSid(&ntAuthority, 2,
        SECURITY_BUILTIN_DOMAIN_RID,
        DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0,
        &adminGroup)
    ) {

        CheckTokenMembership(NULL, adminGroup, &isAdmin);
        FreeSid(adminGroup);
    }
    return isAdmin;
}

std::string to_upper_hex(const std::vector<BYTE>& data) {
    std::ostringstream oss;
    for (BYTE b : data) {
        oss << std::uppercase << std::hex << std::setw(2) << std::setfill('0') << (int)b;
    }
    return oss.str();
}

bool compute_sha256(const std::wstring& path, std::string& hash_out) {
    HANDLE hFile = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
    if (hFile == INVALID_HANDLE_VALUE) return false;

    HCRYPTPROV hProv = 0;
    HCRYPTHASH hHash = 0;
    BYTE buffer[4096];
    DWORD bytesRead;
    std::vector<BYTE> hash(32);

    bool success = false;

    if (CryptAcquireContextW(&hProv, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT)) {
        if (CryptCreateHash(hProv, CALG_SHA_256, 0, 0, &hHash)) {
            while (ReadFile(hFile, buffer, sizeof(buffer), &bytesRead, NULL) && bytesRead > 0) {
                if (!CryptHashData(hHash, buffer, bytesRead, 0)) {
                    break;
                }
            }

            DWORD hashLen = (DWORD)hash.size();
            if (CryptGetHashParam(hHash, HP_HASHVAL, hash.data(), &hashLen, 0)) {
                hash_out = to_upper_hex(hash);
                success = true;
            }

            CryptDestroyHash(hHash);
        }
        CryptReleaseContext(hProv, 0);
    }

    CloseHandle(hFile);
    return success;
}

std::set<std::string> hash_all_driver_files(const std::wstring& directory) {
    std::set<std::string> result;

    for (const auto& entry : std::filesystem::recursive_directory_iterator(directory)) {
        if (entry.is_regular_file() && entry.path().extension() == L".sys") {
            std::string hash;
            if (compute_sha256(entry.path().wstring(), hash)) {
                result.insert(hash);
            }
        }
    }

    return result;
}

enum DRIVER_FLAGS {
    INTERC_MOUSE = 0,
    INTERC_KEYBOARD = 1,
    VIGEMBUS = 2,
};

DLL_EXPORT void get_admin() {
    if (!is_admin()) {
        TCHAR exePath[MAX_PATH];
        GetModuleFileName(NULL, exePath, MAX_PATH);

        ShellExecute(NULL, "runas", exePath, NULL, NULL, SW_SHOWNORMAL);
        exit(0);
    } 
}

DLL_EXPORT uint32_t fetch_req_drivers() {
    get_admin();

    std::wstring driverDir = L"C:\\Windows\\System32\\drivers";
    auto driverMap = hash_all_driver_files(driverDir);

    std::string interc_mouse    = "0F12D47D01864CA5E1EB663A52B3D2C060521E57B68FF99D70E7F01506E400F9";
    std::string interc_keyboard = "2CB5EC142CFAC879BCE4A2F9549258DB972AEBBD24F4551B6B748B464EB7DBA9";
    std::string vigembus        = "B6D6FA5CA8334368FC366A3E78552EFB74EEF657061371B2DE407AA158B0A11C";

    uint32_t interc_mouse_count = driverMap.count(interc_mouse) << INTERC_MOUSE;
    uint32_t interc_keyboard_count = driverMap.count(interc_keyboard) << INTERC_KEYBOARD;
    uint32_t vigembus_count = driverMap.count(vigembus) << VIGEMBUS;

    return interc_mouse_count | interc_keyboard_count | vigembus_count;
}

DLL_EXPORT void install_vigem(const char* drivers_folder) {
    get_admin();

    std::string exe_path = std::string(drivers_folder) + "\\vigembus.exe";

    ShellExecuteA(
        NULL,
        "open",
        exe_path.c_str(),
        nullptr,
        drivers_folder,
        SW_SHOW
    );
}

DLL_EXPORT void install_interception(const char* drivers_folder) {
    get_admin();
    
    std::string exe_path = std::string(drivers_folder) + "\\install-interception.exe";

    ShellExecuteA(
        NULL,
        "open",
        exe_path.c_str(),
        "/install",
        drivers_folder,
        SW_SHOW
    );
}

DLL_EXPORT void restart_pc() {
    HANDLE hToken;
    TOKEN_PRIVILEGES tkp;

    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken)) {
        std::cerr << "Failed to open process token.\n";
        return;
    }

    LookupPrivilegeValue(NULL, SE_SHUTDOWN_NAME, &tkp.Privileges[0].Luid);
    tkp.PrivilegeCount = 1;
    tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

    AdjustTokenPrivileges(hToken, FALSE, &tkp, 0, NULL, 0);
    if (GetLastError() != ERROR_SUCCESS) {
        std::cerr << "Failed to adjust token privileges.\n";
        return;
    }

    if (!ExitWindowsEx(EWX_REBOOT | EWX_FORCE, SHTDN_REASON_MAJOR_SOFTWARE | SHTDN_REASON_FLAG_PLANNED)) {
        std::cerr << "Reboot failed. Error: " << GetLastError() << "\n";
    }
}