from libc.stdint cimport uint64_t

cdef extern from "chiaki/time.h":

    uint64_t chiaki_time_now_monotonic_us()

    uint64_t chiaki_time_now_monotonic_ms()
