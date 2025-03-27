#ifndef _SIGN_HPP
#define _SIGN_HPP

void sha256_hex(const char* input, char* output, size_t output_len);

void get_volume_serial(char* out, size_t len);

void get_cpu_id(char* out, size_t len);

void get_bios_uuid(char* out, size_t len);

void get_mac_address(char* out, size_t len);

void get_hardware_hash(char* buf);

#endif