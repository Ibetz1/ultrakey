#include "main.hpp"

void WinSignal::add(const std::string& name, Callback callbackPtr) {
    if (!callbackPtr) return;

    HANDLE hEvent = CreateEventA(
        NULL,
        FALSE,
        FALSE,
        ("Global\\" + name).c_str()
    );

    if (!hEvent) {
        std::cerr << "[WinSignal] Failed to create/open event '" << name 
                    << "'. Error: " << GetLastError() << "\n";
        return;
    }

    events.push_back(hEvent);
    eventNames.push_back(name);
    callbacks[hEvent] = callbackPtr;
}

void WinSignal::start() {
    pthread_create(&thread, nullptr, &WinSignal::threadEntry, this);
}

void* WinSignal::threadEntry(void* arg) {
    WinSignal* self = static_cast<WinSignal*>(arg);
    self->listenLoop();
    return nullptr;
}

void WinSignal::listenLoop() {
    std::cout << "[WinSignal] Listening for signals...\n";

    while (true) {
        if (events.empty()) {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            continue;
        }

        DWORD result = WaitForMultipleObjects(
            static_cast<DWORD>(events.size()),
            events.data(),
            FALSE,
            INFINITE
        );

        if (result >= WAIT_OBJECT_0 && result < WAIT_OBJECT_0 + events.size()) {
            size_t index = result - WAIT_OBJECT_0;
            HANDLE triggeredEvent = events[index];
            auto it = callbacks.find(triggeredEvent);
            if (it != callbacks.end()) {
                std::cout << "[WinSignal] Signal received: " << eventNames[index] << "\n";
                it->second(); // Call the callback
            }
        } else {
            std::cerr << "[WinSignal] Wait failed. Error: " << GetLastError() << "\n";
            break;
        }
    }
}