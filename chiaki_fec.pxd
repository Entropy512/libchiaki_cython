from libc.stdint cimport uint8_t

cdef extern from "chiaki/fec.h":

    ChiakiErrorCode chiaki_fec_decode(uint8_t* frame_buf, size_t unit_size, size_t stride, unsigned int k, unsigned int m, const unsigned int* erasures, size_t erasures_count)
