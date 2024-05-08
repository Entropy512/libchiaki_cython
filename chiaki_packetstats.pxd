from libc.stdint cimport uint64_t

cdef extern from "chiaki/packetstats.h":

    cdef struct chiaki_packet_stats_t:
        ChiakiMutex mutex
        uint64_t gen_received
        uint64_t gen_lost
        ChiakiSeqNum16 seq_min
        ChiakiSeqNum16 seq_max
        uint64_t seq_received

    ctypedef chiaki_packet_stats_t ChiakiPacketStats

    ChiakiErrorCode chiaki_packet_stats_init(ChiakiPacketStats* stats)

    void chiaki_packet_stats_fini(ChiakiPacketStats* stats)

    void chiaki_packet_stats_reset(ChiakiPacketStats* stats)

    void chiaki_packet_stats_push_generation(ChiakiPacketStats* stats, uint64_t received, uint64_t lost)

    void chiaki_packet_stats_push_seq(ChiakiPacketStats* stats, ChiakiSeqNum16 seq_num)

    void chiaki_packet_stats_get(ChiakiPacketStats* stats, bool reset, uint64_t* received, uint64_t* lost)
