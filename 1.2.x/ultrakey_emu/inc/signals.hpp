#ifndef _WIN_SIGNAL_HPP
#define _WIN_SIGNAL_HPP

struct WinSignal {
public:
    using Callback = void(*)();

    void add(const std::string& name, Callback callbackPtr);
    void start();

private:
    std::vector<HANDLE> events;
    std::vector<std::string> eventNames;
    std::unordered_map<HANDLE, Callback> callbacks;
    pthread_t thread;

    static void* threadEntry(void* arg);

    void listenLoop();
};

#endif