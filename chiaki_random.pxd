from libc.stdint cimport uint8_t, uint32_t

cdef extern from "chiaki/random.h":

    ChiakiErrorCode chiaki_random_bytes_crypt(uint8_t* buf, size_t buf_size)

    uint32_t chiaki_random_32()
