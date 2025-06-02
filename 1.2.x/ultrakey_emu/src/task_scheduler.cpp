#include "main.hpp"

uint64_t get_time_interval() {
    static uint64_t freq_hz = [] {
        LARGE_INTEGER f;
        QueryPerformanceFrequency(&f);
        return f.QuadPart;
    }();

    LARGE_INTEGER counter;
    QueryPerformanceCounter(&counter);
    return (uint64_t)((CLK_TIME_INTERVAL_LL * counter.QuadPart) / freq_hz);
}

InterruptClock::InterruptClock() {
    last_cycle = get_time_interval();
}

InterruptClock::~InterruptClock() {
    for (Interrupt* interrupt : interrupts) {
        delete interrupt;
    }
}

void InterruptClock::tick() {
    bool resync = false;
    uint64_t now = get_time_interval();

    if (now < last_cycle) {
        LOGI("Clock lost alignment now=%lli lc=%lli", now, last_cycle);
        last_cycle = now;
        resync = true;
    }
    
    dt = now - last_cycle;
    last_cycle = now;

    for (Interrupt* interrupt : interrupts) {
        if (resync) {
            interrupt->last_cycle = now;
            interrupt->clock = 0;
            continue;
        }

        interrupt->clock += dt;

        while (interrupt->clock >= interrupt->delay) {
            interrupt->dt = now - interrupt->last_cycle;

            interrupt->callback(interrupt);

            interrupt->last_cycle = now;

            if (interrupt->delay > interrupt->clock) {
                interrupt->clock -= interrupt->delay;
            } else {
                interrupt->clock = 0;
            }
        }

    }
}

Interrupt* InterruptClock::push_interrupt(void* (*callback)(Interrupt*), uint64_t interval_hz, void* context) {
    const uint64_t delay_ns = CLK_TIME_INTERVAL_LL / interval_hz;
    
    uint64_t now = get_time_interval();

    Interrupt* interrupt = new Interrupt {
        .callback = callback,
        .delay = delay_ns,
        .dt = 0,
        .last_cycle = now,
        .context = context,
    };

    interrupts.push_back(interrupt);
    return interrupt;
}

bool template_run_condition(void*) { return true; }

static void* task_wrapper(void* data) {
    TaskData* context = (TaskData*) data;

    while (context->run_condition(context->context) && *(context->global_condition)) {
        context->callback(context->context);
    }

    delete context;
    return nullptr;
}

TaskScheduler::TaskScheduler(int num_tasks) : num_tasks(num_tasks) {
    threads.reserve(num_tasks);
    task_data.reserve(num_tasks);
}

TaskScheduler::~TaskScheduler() {
    stop();
    usleep(100 * 1000);
    LOGI("tasks stopped\n");
}

void TaskScheduler::push(task_callback callback, void* context, task_condition run_condition, bool skip_wait_condition) {
    int id = static_cast<int>(task_data.size());

    TaskData* data = new TaskData {
        .id = id,
        .num_tasks = num_tasks,
        .current_Task_id = &current_running_task,
        .context = context,
        .run_condition = run_condition,
        .callback = callback,
        .global_condition = &global_run_condition,
        .skip_ordered_wait = skip_wait_condition
    };

    task_data.push_back(data);
    pthread_t thread;

    if (pthread_create(&thread, NULL, task_wrapper, data) != 0) {
        THROW("failed to start thread");
        return;
    }

    threads.push_back(thread);
    LOGI("task %d started\n", id);
}

void TaskScheduler::stop() {
    global_run_condition = false;
    for (pthread_t thread : threads) {
        pthread_join(thread, nullptr);
    }
}