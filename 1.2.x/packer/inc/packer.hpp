#ifndef _PACKER_HPP
#define _PACKER_HPP

enum TAG {
    RND = 0x00FF,
    NRM = 0xBB00,
};

uint8_t* import_binary(const char* file, size_t* out_size);

void export_binary(const char* file, uint8_t* data, size_t size);

uint8_t* stagger_buffers(uint8_t* b1, size_t l1, uint8_t* b2, size_t l2, size_t* olen, uint32_t tags = 0);

uint32_t unstagger_buffers(uint8_t* in, uint8_t** out1, uint8_t** out2, size_t* olen1, size_t* olen2);

uint32_t xorshift32(uint32_t* state);

void mask_seed(uint8_t* data, size_t len, uint32_t seed);

uint8_t* merge_binaries(uint8_t* bytes1, uint8_t* bytes2, size_t size1, size_t size2, size_t* out_len, uint32_t sig);

uint32_t extract_binaries(uint8_t* merged, uint8_t** bytes1, uint8_t** bytes2, size_t* size1, size_t* size2);

#endif