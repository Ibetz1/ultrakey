#include "main.hpp"

uint8_t* import_binary(const char* file, size_t* out_size) {
    FILE* f = fopen(file, "rb");

    if (!f) {
        THROW("invalid file ptr %s\n", file);
    }

    long cur = ftell(f);
    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    fseek(f, cur, SEEK_SET);

    uint8_t* buf = (uint8_t*) malloc(size);

    if (!buf) {
        THROW("no mem");
    }

    fread(buf, size, 1, f);
    fclose(f);

    *out_size = size;
    return buf;
}

void export_binary(const char* file, uint8_t* data, size_t size) {
    FILE* f = fopen(file, "wb+");

    if (!f) {
        THROW("invalid file ptr %s\n", file);
    }

    fwrite(data, size, 1, f);
    fclose(f);
}

uint8_t* stagger_buffers(uint8_t* b1, size_t l1, uint8_t* b2, size_t l2, size_t* olen, uint32_t tags) {
    size_t lrg    = (l1 > l2) ? l1 : l2;
    size_t sml    = (l1 <= l2) ? l1 : l2;
    uint8_t* blrg = (l1 > l2) ? b1 : b2;
    uint8_t* bsml = (l1 <= l2) ? b1 : b2;

    size_t fac = lrg / sml;
    size_t rem = lrg % sml;

    size_t total_len = lrg + sml;
    size_t header_len = sizeof(uint32_t) * 3;

    uint8_t* out = (uint8_t*) malloc(header_len + total_len);
    if (!out) {
        THROW("no mem");
        return NULL;
    }

    ((uint32_t*) out)[0] = (uint32_t)tags;
    ((uint32_t*) out)[1] = (uint32_t)l1;
    ((uint32_t*) out)[2] = (uint32_t)l2;

    uint8_t* out_data = out + header_len;

    size_t out_idx = 0, i_lrg = 0, i_sml = 0;

    for (size_t i = 0; i < sml; ++i) {
        for (size_t j = 0; j < fac && i_lrg < lrg; ++j) {
            out_data[out_idx++] = blrg[i_lrg++];
        }
        if (i_sml < sml) {
            out_data[out_idx++] = bsml[i_sml++];
        }
    }

    while (i_lrg < lrg) {
        out_data[out_idx++] = blrg[i_lrg++];
    }

    *olen = header_len + total_len;
    return out;
}

uint32_t unstagger_buffers(uint8_t* in, uint8_t** out1, uint8_t** out2, size_t* olen1, size_t* olen2) {
    if (in == nullptr) {
        THROW("invalid input data");
    }

    uint32_t tags = ((uint32_t*) in)[0];
    uint32_t l1   = ((uint32_t*) in)[1];
    uint32_t l2   = ((uint32_t*) in)[2];

    size_t lrg = (l1 > l2) ? l1 : l2;
    size_t sml = (l1 <= l2) ? l1 : l2;

    *olen1 = l1;
    *olen2 = l2;
    *out1 = (uint8_t*) malloc(l1);
    *out2 = (uint8_t*) malloc(l2);

    uint8_t* blrg = (l1 > l2) ? *out1 : *out2;
    uint8_t* bsml = (l1 <= l2) ? *out1 : *out2;

    if (!blrg || !bsml) {
        THROW("NO MEM");
    }

    uint8_t* data = in + sizeof(uint32_t) * 3;

    size_t fac = lrg / sml;
    size_t rem = lrg % sml;

    size_t i_lrg = 0, i_sml = 0, i_in = 0;
    for (size_t i = 0; i < sml; ++i) {
        for (size_t j = 0; j < fac && i_lrg < lrg; ++j) {
            blrg[i_lrg++] = data[i_in++];
        }
        if (i_sml < sml) {
            bsml[i_sml++] = data[i_in++];
        }
    }

    while (i_lrg < lrg) {
        blrg[i_lrg++] = data[i_in++];
    }

    return tags;
}

uint32_t xorshift32(uint32_t* state) {
    uint32_t x = *state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    return *state = x;
}

void mask_seed(uint8_t* data, size_t len, uint32_t seed) {
    uint32_t state = seed;
    for (size_t i = 0; i < len; ++i) {
        uint8_t rand_byte = xorshift32(&state) & 0xFF;
        data[i] ^= rand_byte;
    }
}

uint8_t* merge_binaries(
    uint8_t* bytes1, 
    uint8_t* bytes2, 
    size_t size1, 
    size_t size2, 
    size_t* out_len,
    uint32_t sig
) {
    uint32_t seed = time(NULL);

    mask_seed(bytes1, size1, seed);
    mask_seed(bytes2, size2, seed);

    size_t stag_len;
    uint8_t* staggered = stagger_buffers(bytes1, size1, bytes2, size2, &stag_len, sig);

    uint8_t seed_bytes[sizeof(uint32_t)] = { 0 };
    memcpy(seed_bytes, &seed, sizeof(uint32_t));

    size_t embed_len;
    uint8_t* embedded = stagger_buffers(staggered, stag_len, seed_bytes, sizeof(uint32_t), &embed_len);

    *out_len = embed_len;
    return embedded;
}

uint32_t extract_binaries(uint8_t* merged, uint8_t** bytes1, uint8_t** bytes2, size_t* size1, size_t* size2) {
    uint8_t* b1;
    uint8_t* b2;
    size_t l1;
    size_t l2;
    unstagger_buffers(merged, &b1, &b2, &l1, &l2);

    uint32_t seed = 0;
    uint32_t flags = 0;
    if (l1 == sizeof(uint32_t)) {
        memcpy(&seed, b1, l1);

        flags = unstagger_buffers(b2, bytes1, bytes2, size1, size2);
    }

    if (l2 == sizeof(uint32_t)) {
        memcpy(&seed, b2, l2);

        flags = unstagger_buffers(b1, bytes1, bytes2, size1, size2);
    }

    mask_seed(*bytes1, *size1, seed);
    mask_seed(*bytes2, *size2, seed);

    return flags;
}