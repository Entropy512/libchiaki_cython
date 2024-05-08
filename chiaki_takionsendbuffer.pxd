from libc.stdint cimport uint8_t

cdef extern from "chiaki/takionsendbuffer.h":

    ctypedef chiaki_takion_t ChiakiTakion

    ctypedef chiaki_takion_send_buffer_packet_t ChiakiTakionSendBufferPacket

    cdef struct chiaki_takion_send_buffer_t:
        ChiakiLog* log
        ChiakiTakion* takion
        ChiakiTakionSendBufferPacket* packets
        size_t packets_size
        size_t packets_count
        ChiakiMutex mutex
        ChiakiCond cond
        bool should_stop
        ChiakiThread thread

    ctypedef chiaki_takion_send_buffer_t ChiakiTakionSendBuffer

    ChiakiErrorCode chiaki_takion_send_buffer_init(ChiakiTakionSendBuffer* send_buffer, ChiakiTakion* takion, size_t size)

    void chiaki_takion_send_buffer_fini(ChiakiTakionSendBuffer* send_buffer)

    ChiakiErrorCode chiaki_takion_send_buffer_push(ChiakiTakionSendBuffer* send_buffer, ChiakiSeqNum32 seq_num, uint8_t* buf, size_t buf_size)

    ChiakiErrorCode chiaki_takion_send_buffer_ack(ChiakiTakionSendBuffer* send_buffer, ChiakiSeqNum32 seq_num, ChiakiSeqNum32* acked_seq_nums, size_t* acked_seq_nums_count)
