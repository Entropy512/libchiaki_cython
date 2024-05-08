from libc.stdint cimport uint8_t, uint32_t

cdef extern from "chiaki/regist.h":

    cdef struct chiaki_regist_info_t:
        ChiakiTarget target
        const char* host
        bool broadcast
        const char* psn_online_id
        uint8_t psn_account_id[8]
        uint32_t pin

    ctypedef chiaki_regist_info_t ChiakiRegistInfo

    cdef struct chiaki_registered_host_t:
        ChiakiTarget target
        char ap_ssid[0x30]
        char ap_bssid[0x20]
        char ap_key[0x50]
        char ap_name[0x20]
        uint8_t server_mac[6]
        char server_nickname[0x20]
        char rp_regist_key[0x10]
        uint32_t rp_key_type
        uint8_t rp_key[0x10]

    ctypedef chiaki_registered_host_t ChiakiRegisteredHost

    cpdef enum chiaki_regist_event_type_t:
        CHIAKI_REGIST_EVENT_TYPE_FINISHED_CANCELED
        CHIAKI_REGIST_EVENT_TYPE_FINISHED_FAILED
        CHIAKI_REGIST_EVENT_TYPE_FINISHED_SUCCESS

    ctypedef chiaki_regist_event_type_t ChiakiRegistEventType

    cdef struct chiaki_regist_event_t:
        ChiakiRegistEventType type
        ChiakiRegisteredHost* registered_host

    ctypedef chiaki_regist_event_t ChiakiRegistEvent

    ctypedef void (*ChiakiRegistCb)(ChiakiRegistEvent* event, void* user)

    cdef struct chiaki_regist_t:
        ChiakiLog* log
        ChiakiRegistInfo info
        ChiakiRegistCb cb
        void* cb_user
        ChiakiThread thread
        ChiakiStopPipe stop_pipe

    ctypedef chiaki_regist_t ChiakiRegist

    ChiakiErrorCode chiaki_regist_start(ChiakiRegist* regist, ChiakiLog* log, const ChiakiRegistInfo* info, ChiakiRegistCb cb, void* cb_user)

    void chiaki_regist_fini(ChiakiRegist* regist)

    void chiaki_regist_stop(ChiakiRegist* regist)

    ChiakiErrorCode chiaki_regist_request_payload_format(ChiakiTarget target, const uint8_t* ambassador, uint8_t* buf, size_t* buf_size, ChiakiRPCrypt* crypt, const char* psn_online_id, const uint8_t* psn_account_id, uint32_t pin)
