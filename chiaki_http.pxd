from libc.stdint cimport uint64_t

cdef extern from "chiaki/http.h":

    cdef struct chiaki_http_header_t:
        const char* key
        const char* value
        chiaki_http_header_t* next

    ctypedef chiaki_http_header_t ChiakiHttpHeader

    cdef struct chiaki_http_response_t:
        int code
        ChiakiHttpHeader* headers

    ctypedef chiaki_http_response_t ChiakiHttpResponse

    void chiaki_http_header_free(ChiakiHttpHeader* header)

    ChiakiErrorCode chiaki_http_header_parse(ChiakiHttpHeader** header, char* buf, size_t buf_size)

    void chiaki_http_response_fini(ChiakiHttpResponse* response)

    ChiakiErrorCode chiaki_http_response_parse(ChiakiHttpResponse* response, char* buf, size_t buf_size)

    ChiakiErrorCode chiaki_recv_http_header(int sock, char* buf, size_t buf_size, size_t* header_size, size_t* received_size, ChiakiStopPipe* stop_pipe, uint64_t timeout_ms)
