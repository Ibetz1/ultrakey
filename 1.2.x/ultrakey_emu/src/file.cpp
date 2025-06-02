#include "main.hpp"

File::File() {}

File::~File() {
    if (this->len > 0) {
        free(this->buffer);
        this->buffer = nullptr;
        this->len = 0;
    }
}

void File::read_path(const char* path) {
    LOGI("reading file data from path %s", path);

    if (this->len > 0 && this->buffer) {
        LOGI("old file data found in file object, it will be overwritten");
        free(this->buffer);
        this->buffer = nullptr;
        this->len = 0;
    }

    FILE* file = fopen(path, "rb");
    if (!file) {
        THROW("invalid file path %s", path);
        return;
    }
    
    struct stat file_stats;

    if (fstat(fileno(file), &file_stats) != 0) {
        fclose(file);
        THROW("failed to get file stats for path %s", path);
        return;
    }

    this->len = (size_t) file_stats.st_size;
    this->buffer = (BYTE*) malloc(this->len + 1);

    if (!this->buffer) {
        THROW("no mem");
        return;
    }

    size_t bytes_read = fread(this->buffer, 1, this->len, file);
    this->buffer[this->len] = '\0';
    fclose(file);

    if (bytes_read != this->len) {
        THROW("invalid file read, size misalignment");
        return;
    }

    LOGI("file data read success");
}

void File::write_buffer(const char* path, BYTE* allocated, size_t len) {
    LOGI("reading file data from path %s", path);

    FILE* file = fopen(path, "wb+");
    if (!file) {
        THROW("invalid file path %s", path);
        return;
    }
    
    size_t written = fwrite(allocated, 1, len, file);

    fclose(file);
    LOGI("file data write success");
}

// returns const reference to data
BYTE* File::data() const {
    return this->buffer;
}

// returns const reference to size
size_t File::size() const {
    return this->len;
}

void File::print_bytes() {
    for (int i = 0; i < this-> len; ++i) {
        printf("[%i: %2x] ", i, this->buffer[i]);
    }

    printf("\n");
}