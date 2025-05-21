#ifndef _TASK_SCHEDULER_HPP
#define _TASK_SCHEDULER_HPP

uint64_t get_time_interval();

struct Interrupt {
    void* (*callback)(Interrupt*);
    uint64_t clock = 0;
    uint64_t delay;

    uint64_t dt = 0;
    uint64_t last_cycle = 0;
    void* context;
};

struct InterruptClock {
    std::vector<Interrupt*> interrupts;
    uint64_t start_time = 0;
    uint64_t last_cycle = 0;
    uint64_t dt = 0;

    InterruptClock();
    ~InterruptClock();

    void tick();

    Interrupt* push_interrupt(void* (*callback)(Interrupt*), uint64_t interval_hz, void* context=nullptr);
};

typedef bool(*task_condition)(void*);
typedef void*(*task_callback)(void*);

bool template_run_condition(void*);

struct TaskData {
    int id;
    int num_tasks;
    int* current_Task_id;
    void* context;
    task_condition run_condition;
    task_callback callback;
    bool* global_condition;
    bool skip_ordered_wait;
};

struct TaskScheduler {
    int num_tasks = 0;
    int current_running_task = 0;
    bool global_run_condition = true;
    std::vector<pthread_t> threads;
    std::vector<TaskData*> task_data;

    TaskScheduler(int num_tasks);
    ~TaskScheduler();

    void push(task_callback callback, void* context, task_condition run_condition = template_run_condition, bool skip_wait_condition = false);

    void stop();
};

#endif