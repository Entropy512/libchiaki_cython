from libc.stdint cimport uint8_t

cdef extern from "chiaki/base64.h":

    ChiakiErrorCode chiaki_base64_encode(const uint8_t* in_, size_t in_size, char* out, size_t out_size)

    ChiakiErrorCode chiaki_base64_decode(const char* in_, size_t in_size, uint8_t* out, size_t* out_size)
