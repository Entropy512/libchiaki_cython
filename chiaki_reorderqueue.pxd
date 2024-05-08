from libc.stdint cimport uint64_t

cdef extern from "chiaki/reorderqueue.h":

    cpdef enum chiaki_reorder_queue_drop_strategy_t:
        CHIAKI_REORDER_QUEUE_DROP_STRATEGY_BEGIN
        CHIAKI_REORDER_QUEUE_DROP_STRATEGY_END

    ctypedef chiaki_reorder_queue_drop_strategy_t ChiakiReorderQueueDropStrategy

    cdef struct chiaki_reorder_queue_entry_t:
        void* user
        bool set

    ctypedef chiaki_reorder_queue_entry_t ChiakiReorderQueueEntry

    ctypedef void (*ChiakiReorderQueueDropCb)(uint64_t seq_num, void* elem_user, void* cb_user)

    ctypedef bool (*ChiakiReorderQueueSeqNumGt)(uint64_t a, uint64_t b)

    ctypedef bool (*ChiakiReorderQueueSeqNumLt)(uint64_t a, uint64_t b)

    ctypedef uint64_t (*ChiakiReorderQueueSeqNumAdd)(uint64_t a, uint64_t b)

    ctypedef uint64_t (*ChiakiReorderQueueSeqNumSub)(uint64_t a, uint64_t b)

    cdef struct chiaki_reorder_queue_t:
        size_t size_exp
        ChiakiReorderQueueEntry* queue
        uint64_t begin
        uint64_t count
        ChiakiReorderQueueSeqNumGt seq_num_gt
        ChiakiReorderQueueSeqNumLt seq_num_lt
        ChiakiReorderQueueSeqNumAdd seq_num_add
        ChiakiReorderQueueSeqNumSub seq_num_sub
        ChiakiReorderQueueDropStrategy drop_strategy
        ChiakiReorderQueueDropCb drop_cb
        void* drop_cb_user

    ctypedef chiaki_reorder_queue_t ChiakiReorderQueue

    ChiakiErrorCode chiaki_reorder_queue_init(ChiakiReorderQueue* queue, size_t size_exp, uint64_t seq_num_start, ChiakiReorderQueueSeqNumGt seq_num_gt, ChiakiReorderQueueSeqNumLt seq_num_lt, ChiakiReorderQueueSeqNumAdd seq_num_add)

    ChiakiErrorCode chiaki_reorder_queue_init_16(ChiakiReorderQueue* queue, size_t size_exp, ChiakiSeqNum16 seq_num_start)

    ChiakiErrorCode chiaki_reorder_queue_init_32(ChiakiReorderQueue* queue, size_t size_exp, ChiakiSeqNum32 seq_num_start)

    void chiaki_reorder_queue_fini(ChiakiReorderQueue* queue)

    void chiaki_reorder_queue_set_drop_strategy(ChiakiReorderQueue* queue, ChiakiReorderQueueDropStrategy drop_strategy)

    void chiaki_reorder_queue_set_drop_cb(ChiakiReorderQueue* queue, ChiakiReorderQueueDropCb cb, void* user)

    size_t chiaki_reorder_queue_size(ChiakiReorderQueue* queue)

    uint64_t chiaki_reorder_queue_count(ChiakiReorderQueue* queue)

    void chiaki_reorder_queue_push(ChiakiReorderQueue* queue, uint64_t seq_num, void* user)

    bool chiaki_reorder_queue_pull(ChiakiReorderQueue* queue, uint64_t* seq_num, void** user)

    bool chiaki_reorder_queue_peek(ChiakiReorderQueue* queue, uint64_t index, uint64_t* seq_num, void** user)

    void chiaki_reorder_queue_drop(ChiakiReorderQueue* queue, uint64_t index)
