from libc.stdint cimport uint32_t, uint8_t

cdef extern from "chiaki/log.h":

    ctypedef enum ChiakiLogLevel:
        CHIAKI_LOG_DEBUG
        CHIAKI_LOG_VERBOSE
        CHIAKI_LOG_INFO
        CHIAKI_LOG_WARNING
        CHIAKI_LOG_ERROR

    char chiaki_log_level_char(ChiakiLogLevel level)

    ctypedef void (*ChiakiLogCb)(ChiakiLogLevel level, const char* msg, void* user)

    cdef struct chiaki_log_t:
        uint32_t level_mask
        ChiakiLogCb cb
        void* user

    ctypedef chiaki_log_t ChiakiLog

    void chiaki_log_init(ChiakiLog* log, uint32_t level_mask, ChiakiLogCb cb, void* user)

    void chiaki_log_cb_print(ChiakiLogLevel level, const char* msg, void* user)

    void chiaki_log(ChiakiLog* log, ChiakiLogLevel level, const char* fmt)

    void chiaki_log_hexdump(ChiakiLog* log, ChiakiLogLevel level, const uint8_t* buf, size_t buf_size)

    void chiaki_log_hexdump_raw(ChiakiLog* log, ChiakiLogLevel level, const uint8_t* buf, size_t buf_size)

    cdef struct chiaki_log_sniffer_t:
        ChiakiLog* forward_log
        ChiakiLog sniff_log
        uint32_t sniff_level_mask
        char* buf
        size_t buf_len

    ctypedef chiaki_log_sniffer_t ChiakiLogSniffer

    void chiaki_log_sniffer_init(ChiakiLogSniffer* sniffer, uint32_t level_mask, ChiakiLog* forward_log)

    void chiaki_log_sniffer_fini(ChiakiLogSniffer* sniffer)

    ChiakiLog* chiaki_log_sniffer_get_log(ChiakiLogSniffer* sniffer)

    const char* chiaki_log_sniffer_get_buffer(ChiakiLogSniffer* sniffer)
