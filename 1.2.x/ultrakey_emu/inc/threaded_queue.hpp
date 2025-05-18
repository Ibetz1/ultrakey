#ifndef _THREADED_QUEUE_HPP
#define _THREADED_QUEUE_HPP

template<typename T>
class ThreadedQueue {
public:
    ThreadedQueue() {
        pthread_mutex_init(&mutex, nullptr);
        pthread_cond_init(&cond, nullptr);
    }

    ~ThreadedQueue() {
        pthread_mutex_destroy(&mutex);
        pthread_cond_destroy(&cond);
    }

    void push(const T& item) {
        pthread_mutex_lock(&mutex);
        queue.push(item);
        pthread_cond_signal(&cond);  // Notify a waiting thread
        pthread_mutex_unlock(&mutex);
    }

    T pop() {
        pthread_mutex_lock(&mutex);
        while (queue.empty()) {
            pthread_cond_wait(&cond, &mutex);
        }
        T item = queue.front();
        queue.pop();
        pthread_mutex_unlock(&mutex);
        return item;
    }

    bool try_pop(T& result) {
        pthread_mutex_lock(&mutex);
        if (queue.empty()) {
            pthread_mutex_unlock(&mutex);
            return false;
        }
        result = queue.front();
        queue.pop();
        pthread_mutex_unlock(&mutex);
        return true;
    }

    void with_front(std::function<bool(T&)> func) {
        pthread_mutex_lock(&mutex);
        if (!queue.empty()) {
            T& front = queue.front();
            bool should_pop = func(front);
            if (should_pop) {
                queue.pop();
            }
        }
        pthread_mutex_unlock(&mutex);
    }

private:
    std::queue<T> queue;
    pthread_mutex_t mutex;
    pthread_cond_t cond;
};

#endif