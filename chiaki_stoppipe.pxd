from libc.stdint cimport uint64_t

cdef extern from "chiaki/stoppipe.h":

    cdef struct chiaki_stop_pipe_t:
        int fds[2]

    ctypedef chiaki_stop_pipe_t ChiakiStopPipe

    cdef struct sockaddr

    ChiakiErrorCode chiaki_stop_pipe_init(ChiakiStopPipe* stop_pipe)

    void chiaki_stop_pipe_fini(ChiakiStopPipe* stop_pipe)

    void chiaki_stop_pipe_stop(ChiakiStopPipe* stop_pipe)

    ChiakiErrorCode chiaki_stop_pipe_select_single(ChiakiStopPipe* stop_pipe, chiaki_socket_t fd, bool write, uint64_t timeout_ms)

    ChiakiErrorCode chiaki_stop_pipe_connect(ChiakiStopPipe* stop_pipe, chiaki_socket_t fd, sockaddr* addr, size_t addrlen)

    ChiakiErrorCode chiaki_stop_pipe_sleep(ChiakiStopPipe* stop_pipe, uint64_t timeout_ms)

    ChiakiErrorCode chiaki_stop_pipe_reset(ChiakiStopPipe* stop_pipe)
