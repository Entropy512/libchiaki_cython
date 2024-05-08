from libc.stdint cimport uint8_t

cdef extern from "chiaki/video.h":

    cdef struct chiaki_video_profile_t:
        unsigned int width
        unsigned int height
        size_t header_sz
        uint8_t* header

    ctypedef chiaki_video_profile_t ChiakiVideoProfile
