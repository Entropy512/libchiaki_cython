from libc.stdint cimport uint64_t, uint16_t, uint32_t

cdef extern from "chiaki/senkusha.h":

    ctypedef chiaki_session_t ChiakiSession

    cdef struct senkusha_t:
        ChiakiSession* session
        ChiakiLog* log
        ChiakiTakion takion
        int state
        bool state_finished
        bool state_failed
        bool should_stop
        ChiakiSeqNum32 data_ack_seq_num_expected
        uint64_t pong_time_us
        uint16_t ping_test_index
        uint16_t ping_index
        uint32_t ping_tag
        uint32_t mtu_id
        ChiakiCond state_cond
        ChiakiMutex state_mutex

    ctypedef senkusha_t ChiakiSenkusha

    ChiakiErrorCode chiaki_senkusha_init(ChiakiSenkusha* senkusha, ChiakiSession* session)

    void chiaki_senkusha_fini(ChiakiSenkusha* senkusha)

    ChiakiErrorCode chiaki_senkusha_run(ChiakiSenkusha* senkusha, uint32_t* mtu_in, uint32_t* mtu_out, uint64_t* rtt_us)
