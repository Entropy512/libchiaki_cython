from libc.stdint cimport uint8_t, uint32_t

cdef extern from "chiaki/audio.h":

    cdef struct chiaki_audio_header_t:
        uint8_t channels
        uint8_t bits
        uint32_t rate
        uint32_t frame_size
        uint32_t unknown

    ctypedef chiaki_audio_header_t ChiakiAudioHeader

    void chiaki_audio_header_load(ChiakiAudioHeader* audio_header, const uint8_t* buf)

    void chiaki_audio_header_save(ChiakiAudioHeader* audio_header, uint8_t* buf)

    size_t chiaki_audio_header_frame_buf_size(ChiakiAudioHeader* audio_header)
