#ifndef _FILE_HPP
#define _FILE_HPP

struct File {
private:
    BYTE* buffer = nullptr;
    size_t len = 0;

public:
    File();

    // destroy file object
    ~File();

    // read bytes into file object
    void read_path(const char* path);

    void write_buffer(const char* path, BYTE* allocated, size_t len);

    // returns const reference to data
    BYTE* data() const;

    // returns const reference to size
    size_t size() const;

    // prints out bytes in 2 nibble chunks
    void print_bytes();
};

#endif