from libc.stdint cimport uint16_t, uint32_t

cdef extern from "chiaki/seqnum.h":

    ctypedef uint16_t ChiakiSeqNum16

    bool chiaki_seq_num_16_lt(ChiakiSeqNum16 a, ChiakiSeqNum16 b)

    bool chiaki_seq_num_16_gt(ChiakiSeqNum16 a, ChiakiSeqNum16 b)

    ctypedef uint32_t ChiakiSeqNum32

    bool chiaki_seq_num_32_lt(ChiakiSeqNum32 a, ChiakiSeqNum32 b)

    bool chiaki_seq_num_32_gt(ChiakiSeqNum32 a, ChiakiSeqNum32 b)
