#ifndef OBFSTR_H
#define OBFSTR_H

template <std::size_t N, uint8_t Key>
struct XorLiteral {
    char data[N]{};

    consteval XorLiteral(const char (&str)[N]) {
        for (std::size_t i = 0; i < N; ++i)
            data[i] = str[i] ^ Key;
    }

    const char* decrypt() {
        for (std::size_t i = 0; i < N; ++i)
            data[i] ^= Key;
        return data;
    }

    void decrypt_rt(char* out) const {
        for (std::size_t i = 0; i < N; ++i)
            out[i] = data[i] ^ Key;
    }
};

inline static void obf_decrypt(char* out, const char* in, size_t len, uint8_t key) {
    for (size_t i = 0; i < len; ++i) {
        out[i] = in[i] ^ key;
    }
    out[len] = '\0';
}

#define STR(str) XorLiteral<sizeof(str), 0xA5>(str).decrypt()
#define MAKE_OBF(name, str) \
    constexpr static XorLiteral<sizeof(str), 0xA5> name(str)

// printf("%s %s\n", STR("packed.bin"), STR("ultrakey_ui.exe"));

constexpr const char mdcr_table_dfipt[] = {
    'p' ^ (char) 0xA5, 
    'a' ^ (char) 0xA5, 
    'c' ^ (char) 0xA5, 
    'k' ^ (char) 0xA5, 
    'e' ^ (char) 0xA5, 
    'd' ^ (char) 0xA5, 
    '.' ^ (char) 0xA5, 
    'b' ^ (char) 0xA5, 
    'i' ^ (char) 0xA5, 
    'n' ^ (char) 0xA5,
    0
};

constexpr char mdcr_table_dfopt[] = {
    'u' ^ (char) 0x4A, 
    'l' ^ (char) 0x4A, 
    't' ^ (char) 0x4A, 
    'r' ^ (char) 0x4A, 
    'a' ^ (char) 0x4A, 
    'k' ^ (char) 0x4A, 
    'e' ^ (char) 0x4A,
    'y' ^ (char) 0x4A, 
    '_' ^ (char) 0x4A, 
    'u' ^ (char) 0x4A, 
    'i' ^ (char) 0x4A, 
    '.' ^ (char) 0x4A, 
    'e' ^ (char) 0x4A, 
    'x' ^ (char) 0x4A, 
    'e' ^ (char) 0x4A,
    0
};

constexpr char mdcr_table_dfuke[] = {
    's' ^ (char) 0x3C, 
    'a' ^ (char) 0x3C, 
    'l' ^ (char) 0x3C, 
    't' ^ (char) 0x3C, 
    '.' ^ (char) 0x3C, 
    'u' ^ (char) 0x3C, 
    'k' ^ (char) 0x3C,
    's' ^ (char) 0x3C, 
    0
};

#endif