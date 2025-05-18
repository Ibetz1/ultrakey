#ifndef _TASK_SCHEDULER_HPP
#define _TASK_SCHEDULER_HPP

uint64_t get_time_ns();

uint64_t get_dt_ns(uint64_t* last_time_ns);

void wait_ns(uint64_t ns);
void wait_us(uint64_t us);
void wait_ms(uint64_t ms);

struct Clock {
    float dt_ms = 0.f;
    float second_timer = 0.f;
    int frame_count = 0;
    uint64_t start_time_ns = 0;
    uint64_t last_cycle = get_time_ns();
    uint64_t dt_ns = 0;
    bool show_fps = false;

    void begin();
    void end();
    void end(uint64_t khz);
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
    pthread_mutex_t* mutex;
    pthread_cond_t* condition;
    bool* global_condition;
    bool skip_ordered_wait;
};

struct TaskScheduler {
    int num_tasks = 0;
    int current_running_task = 0;
    bool global_run_condition = true;
    pthread_mutex_t task_shared_mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_cond_t task_shared_condition = PTHREAD_COND_INITIALIZER;
    std::vector<pthread_t> threads;
    std::vector<TaskData*> task_data;

    TaskScheduler(int num_tasks);
    ~TaskScheduler();

    void push(task_callback callback, void* context, task_condition run_condition = template_run_condition, bool skip_wait_condition = false);

    void stop();
};

#endif