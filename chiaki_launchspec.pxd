from libc.stdint cimport uint8_t

cdef extern from "chiaki/launchspec.h":

    cdef struct chiaki_launch_spec_t:
        ChiakiTarget target
        unsigned int mtu
        unsigned int rtt
        uint8_t* handshake_key
        unsigned int width
        unsigned int height
        unsigned int max_fps
        ChiakiCodec codec
        unsigned int bw_kbps_sent

    ctypedef chiaki_launch_spec_t ChiakiLaunchSpec

    int chiaki_launchspec_format(char* buf, size_t buf_size, ChiakiLaunchSpec* launch_spec)
