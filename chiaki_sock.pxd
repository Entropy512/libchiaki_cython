cdef extern from "chiaki/sock.h":

    ctypedef int chiaki_socket_t

    ChiakiErrorCode chiaki_socket_set_nonblock(chiaki_socket_t sock, bool nonblock)
