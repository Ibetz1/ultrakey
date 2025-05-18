#include "main.hpp"

uint64_t get_time_ns() {
    LARGE_INTEGER freq, counter;
    QueryPerformanceFrequency(&freq);
    QueryPerformanceCounter(&counter);
    return (uint64_t)((1e9 * counter.QuadPart) / freq.QuadPart);
}

uint64_t get_dt_ns(uint64_t* last_time_ns) {
    uint64_t now = get_time_ns();
    uint64_t dt = now - *last_time_ns;
    *last_time_ns = now;
    return dt;
}

void wait_ns(uint64_t ns) {
    uint64_t start = get_time_ns();
    while ((get_time_ns() - start) < ns) {
        __asm__ __volatile__("pause" ::: "memory");
    }
}

void wait_us(uint64_t us) {
    wait_ns(us * 1000);
}

void wait_ms(uint64_t ms) {
    wait_ns(ms * 1000000);
}

void Clock::begin() {
    dt_ms = NS_TO_MS(dt_ns);
    start_time_ns = get_time_ns();
}

void Clock::end() {
    uint64_t now = get_time_ns();
    dt_ns = now - start_time_ns;
    dt_ms = (float) (dt_ns) / 1'000'000.0f;
    last_cycle = now;

    second_timer += dt_ms / 1000.f;
    frame_count++;

    if (second_timer >= 1.f) {
        if (show_fps)
            LOGI("FPS: %i", frame_count);
        frame_count = 0;
        second_timer = 0.f;
    }
}

void Clock::end(uint64_t khz) {
    const uint64_t now = get_time_ns();
    dt_ns = now - start_time_ns;

    const uint64_t target_ns = 1'000'000'000ULL / khz;

    if (dt_ns < target_ns) {
        wait_ns(target_ns - dt_ns);
        dt_ns = target_ns;
    }

    dt_ms = (float)(dt_ns) / 1'000'000.0f;
    last_cycle = get_time_ns();  // actual time after wait

    second_timer += dt_ms / 1000.f;
    frame_count++;

    if (second_timer >= 1.f) {
        if (show_fps)
            LOGI("FPS: %i", frame_count);
        frame_count = 0;
        second_timer = 0.f;
    }
}

bool template_run_condition(void*) { return true; }

static void* task_wrapper(void* data) {
    TaskData* context = (TaskData*) data;

    while (context->run_condition(context->context) && *(context->global_condition)) {
        pthread_mutex_lock(context->mutex);

        while (!context->skip_ordered_wait && *context->current_Task_id != context->id) {
            pthread_cond_wait(context->condition, context->mutex);
        }

        context->callback(context->context);

        if (!context->skip_ordered_wait) {
            *context->current_Task_id = (*context->current_Task_id + 1) % context->num_tasks;
            pthread_cond_broadcast(context->condition);
        }

        pthread_mutex_unlock(context->mutex);
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
        .mutex = &task_shared_mutex,
        .condition = &task_shared_condition,
        .global_condition = &global_run_condition,
        .skip_ordered_wait = skip_wait_condition
    };

    task_data.push_back(data);
    pthread_t thread;

    if (pthread_create(&thread, NULL, task_wrapper, data) != 0) {
        THROW("failed to start thread");
    }

    threads.push_back(thread);
    // pthread_detach(thread);
    LOGI("task %d started\n", id);
}

void TaskScheduler::stop() {
    global_run_condition = false;
    for (pthread_t thread : threads) {
        pthread_join(thread, nullptr);
    }
}

// bool template_run_condition(void*) { return true; }

// static void* task_wrapper(void* data) {
//     TaskData* context = (TaskData*) data;

//     while (context->run_condition(context->context) && *(context->global_condition)) {
//         pthread_mutex_lock(context->mutex);

//         while (*context->current_Task_id != context->id) {
//             pthread_cond_wait(context->condition, context->mutex);
//         }

//         context->callback(context->context);

//         *context->current_Task_id = (*(context->current_Task_id) + 1) % context->num_tasks;
//         pthread_cond_broadcast(context->condition);

//         pthread_mutex_unlock(context->mutex);

//         // TODO: delay hz
//     }

//     delete context;
//     return nullptr;
// }

// TaskScheduler::TaskScheduler(int num_tasks) : num_tasks(num_tasks) {
//     threads = (pthread_t*) calloc(sizeof(pthread_t), num_tasks);
//     task_data = (TaskData**) calloc(sizeof(TaskData*), num_tasks);
// }

// TaskScheduler::~TaskScheduler() {
//     stop();
//     usleep(100 * 1000);
//     LOGI("tasks stopped");
// }

// void TaskScheduler::push(task_callback callback, void* context, task_condition run_condition, bool skip_wait_condition) {
//     TaskData* data = new TaskData {
//         .id = used_tasks,
//         .num_tasks = num_tasks,
//         .current_Task_id = &current_running_task,
//         .context = context,
//         .run_condition = run_condition,
//         .callback = callback,
//         .mutex = &task_shared_mutex,
//         .condition = &task_shared_condition,
//         .global_condition = &global_run_condition,
//         .skip_ordered_wait = skip_wait_condition
//     };

//     task_data[used_tasks] = data;

//     if (pthread_create(&threads[used_tasks], NULL, task_wrapper, data)) {
//         THROW("failed to start thread");
//     } else {
//         LOGI("input interface started");
//     }

//     pthread_detach(threads[used_tasks]);

//     used_tasks++;
// }

// void TaskScheduler::stop() {
//     global_run_condition = false;
// }