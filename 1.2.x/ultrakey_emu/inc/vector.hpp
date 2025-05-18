#ifndef _VECTOR_HPP
#define _VECTOR_HPP

template<typename T>
struct Vec {
    T x, y;

    Vec<float> direction() {
        float mag = size();
        if (mag > 1.f) {
            return { (float) x / mag, (float) y / mag };
        }

        return { (float) x, (float) y };
    }

    float size() {
        float mag = sqrtf(x * x + y * y);
        return mag;
    }

    static Vec<T> polar(float ang, float mag) {
        return {
            cos(ang) * mag,
            sin(ang) * mag,
        };
    }

    Vec<T> add(Vec<T> other) {
        this->x += other.x;
        this->y += other.y;
        return *this;
    }

    Vec<T> mul(Vec<T> other) {
        this->x *= other.x;
        this->y *= other.y;
        return *this;
    }

    Vec<T> div(Vec<T> other) {
        this->x /= other.x;
        this->y /= other.y;
        return *this;
    }

    Vec<T> sub(Vec<T> other) {
        this->x -= other.x;
        this->y -= other.y;
        return *this;
    }

    Vec<T> set(T x, T y) {
        this->x = x;
        this->y = y;
        return *this;
    }
};

#endif