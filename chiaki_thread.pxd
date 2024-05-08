from libc.stdint cimport uint64_t

cdef extern from "chiaki/thread.h":

    ctypedef void* (*ChiakiThreadFunc)(void*)

    cdef struct chiaki_thread_t:
        pthread_t thread

    ctypedef chiaki_thread_t ChiakiThread

    ChiakiErrorCode chiaki_thread_create(ChiakiThread* thread, ChiakiThreadFunc func, void* arg)

    ChiakiErrorCode chiaki_thread_join(ChiakiThread* thread, void** retval)

    ChiakiErrorCode chiaki_thread_set_name(ChiakiThread* thread, const char* name)

    cdef struct chiaki_mutex_t:
        pthread_mutex_t mutex

    ctypedef chiaki_mutex_t ChiakiMutex

    ChiakiErrorCode chiaki_mutex_init(ChiakiMutex* mutex, bool rec)

    ChiakiErrorCode chiaki_mutex_fini(ChiakiMutex* mutex)

    ChiakiErrorCode chiaki_mutex_lock(ChiakiMutex* mutex)

    ChiakiErrorCode chiaki_mutex_trylock(ChiakiMutex* mutex)

    ChiakiErrorCode chiaki_mutex_unlock(ChiakiMutex* mutex)

    cdef struct chiaki_cond_t:
        pthread_cond_t cond

    ctypedef chiaki_cond_t ChiakiCond

    ctypedef bool (*ChiakiCheckPred)(void*)

    ChiakiErrorCode chiaki_cond_init(ChiakiCond* cond)

    ChiakiErrorCode chiaki_cond_fini(ChiakiCond* cond)

    ChiakiErrorCode chiaki_cond_wait(ChiakiCond* cond, ChiakiMutex* mutex)

    ChiakiErrorCode chiaki_cond_timedwait(ChiakiCond* cond, ChiakiMutex* mutex, uint64_t timeout_ms)

    ChiakiErrorCode chiaki_cond_wait_pred(ChiakiCond* cond, ChiakiMutex* mutex, ChiakiCheckPred check_pred, void* check_pred_user)

    ChiakiErrorCode chiaki_cond_timedwait_pred(ChiakiCond* cond, ChiakiMutex* mutex, uint64_t timeout_ms, ChiakiCheckPred check_pred, void* check_pred_user)

    ChiakiErrorCode chiaki_cond_signal(ChiakiCond* cond)

    ChiakiErrorCode chiaki_cond_broadcast(ChiakiCond* cond)

    cdef struct chiaki_bool_pred_cond_t:
        ChiakiCond cond
        ChiakiMutex mutex
        bool pred

    ctypedef chiaki_bool_pred_cond_t ChiakiBoolPredCond

    ChiakiErrorCode chiaki_bool_pred_cond_init(ChiakiBoolPredCond* cond)

    ChiakiErrorCode chiaki_bool_pred_cond_fini(ChiakiBoolPredCond* cond)

    ChiakiErrorCode chiaki_bool_pred_cond_lock(ChiakiBoolPredCond* cond)

    ChiakiErrorCode chiaki_bool_pred_cond_unlock(ChiakiBoolPredCond* cond)

    ChiakiErrorCode chiaki_bool_pred_cond_wait(ChiakiBoolPredCond* cond)

    ChiakiErrorCode chiaki_bool_pred_cond_timedwait(ChiakiBoolPredCond* cond, uint64_t timeout_ms)

    ChiakiErrorCode chiaki_bool_pred_cond_signal(ChiakiBoolPredCond* cond)

    ChiakiErrorCode chiaki_bool_pred_cond_broadcast(ChiakiBoolPredCond* cond)
