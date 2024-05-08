from libc.stdint cimport uint32_t, uint16_t

cdef extern from "chiaki/common.h":

    ctypedef uint32_t chiaki_unaligned_uint32_t

    ctypedef uint16_t chiaki_unaligned_uint16_t

    ctypedef enum ChiakiErrorCode:
        CHIAKI_ERR_SUCCESS
        CHIAKI_ERR_UNKNOWN
        CHIAKI_ERR_PARSE_ADDR
        CHIAKI_ERR_THREAD
        CHIAKI_ERR_MEMORY
        CHIAKI_ERR_OVERFLOW
        CHIAKI_ERR_NETWORK
        CHIAKI_ERR_CONNECTION_REFUSED
        CHIAKI_ERR_HOST_DOWN
        CHIAKI_ERR_HOST_UNREACH
        CHIAKI_ERR_DISCONNECTED
        CHIAKI_ERR_INVALID_DATA
        CHIAKI_ERR_BUF_TOO_SMALL
        CHIAKI_ERR_MUTEX_LOCKED
        CHIAKI_ERR_CANCELED
        CHIAKI_ERR_TIMEOUT
        CHIAKI_ERR_INVALID_RESPONSE
        CHIAKI_ERR_INVALID_MAC
        CHIAKI_ERR_UNINITIALIZED
        CHIAKI_ERR_FEC_FAILED
        CHIAKI_ERR_VERSION_MISMATCH

    const char* chiaki_error_string(ChiakiErrorCode code)

    void* chiaki_aligned_alloc(size_t alignment, size_t size)

    void chiaki_aligned_free(void* ptr)

    ctypedef enum ChiakiTarget:
        CHIAKI_TARGET_PS4_UNKNOWN
        CHIAKI_TARGET_PS4_8
        CHIAKI_TARGET_PS4_9
        CHIAKI_TARGET_PS4_10
        CHIAKI_TARGET_PS5_UNKNOWN
        CHIAKI_TARGET_PS5_1

    bool chiaki_target_is_unknown(ChiakiTarget target)

    bool chiaki_target_is_ps5(ChiakiTarget target)

    ChiakiErrorCode chiaki_lib_init()

    ctypedef enum ChiakiCodec:
        CHIAKI_CODEC_H264
        CHIAKI_CODEC_H265
        CHIAKI_CODEC_H265_HDR

    bool chiaki_codec_is_h265(ChiakiCodec codec)

    bool chiaki_codec_is_hdr(ChiakiCodec codec)

    const char* chiaki_codec_name(ChiakiCodec codec)
