from libc.stdint cimport uint32_t, uint16_t, uint64_t, uint8_t
from chiaki_common cimport *
from chiaki_thread cimport *
from chiaki_stoppipe import *
from chiaki_log cimport *
cdef extern from "chiaki/discovery.h":

    cpdef enum chiaki_discovery_cmd_t:
        CHIAKI_DISCOVERY_CMD_SRCH
        CHIAKI_DISCOVERY_CMD_WAKEUP

    ctypedef chiaki_discovery_cmd_t ChiakiDiscoveryCmd

    cdef struct chiaki_discovery_packet_t:
        ChiakiDiscoveryCmd cmd
        char* protocol_version
        uint64_t user_credential

    ctypedef chiaki_discovery_packet_t ChiakiDiscoveryPacket

    cpdef enum chiaki_discovery_host_state_t:
        CHIAKI_DISCOVERY_HOST_STATE_UNKNOWN
        CHIAKI_DISCOVERY_HOST_STATE_READY
        CHIAKI_DISCOVERY_HOST_STATE_STANDBY

    ctypedef chiaki_discovery_host_state_t ChiakiDiscoveryHostState

    const char* chiaki_discovery_host_state_string(ChiakiDiscoveryHostState state)

    cdef struct chiaki_discovery_host_t:
        ChiakiDiscoveryHostState state
        uint16_t host_request_port
        const char* host_addr
        const char* system_version
        const char* device_discovery_protocol_version
        const char* host_name
        const char* host_type
        const char* host_id
        const char* running_app_titleid
        const char* running_app_name

    ctypedef chiaki_discovery_host_t ChiakiDiscoveryHost

    bool chiaki_discovery_host_is_ps5(ChiakiDiscoveryHost* host)

    ChiakiTarget chiaki_discovery_host_system_version_target(ChiakiDiscoveryHost* host)

    int chiaki_discovery_packet_fmt(char* buf, size_t buf_size, ChiakiDiscoveryPacket* packet)

    cdef struct chiaki_discovery_t:
        ChiakiLog* log
        chiaki_socket_t socket
        sockaddr local_addr

    ctypedef chiaki_discovery_t ChiakiDiscovery

    ChiakiErrorCode chiaki_discovery_init(ChiakiDiscovery* discovery, ChiakiLog* log, sa_family_t family)

    void chiaki_discovery_fini(ChiakiDiscovery* discovery)

    ChiakiErrorCode chiaki_discovery_send(ChiakiDiscovery* discovery, ChiakiDiscoveryPacket* packet, sockaddr* addr, size_t addr_size)

    ctypedef void (*ChiakiDiscoveryCb)(ChiakiDiscoveryHost* host, void* user)

    cdef struct chiaki_discovery_thread_t:
        ChiakiDiscovery* discovery
        ChiakiThread thread
        ChiakiStopPipe stop_pipe
        ChiakiDiscoveryCb cb
        void* cb_user

    ctypedef chiaki_discovery_thread_t ChiakiDiscoveryThread

    ChiakiErrorCode chiaki_discovery_thread_start(ChiakiDiscoveryThread* thread, ChiakiDiscovery* discovery, ChiakiDiscoveryCb cb, void* cb_user)

    ChiakiErrorCode chiaki_discovery_thread_stop(ChiakiDiscoveryThread* thread)

    ChiakiErrorCode chiaki_discovery_wakeup(ChiakiLog* log, ChiakiDiscovery* discovery, const char* host, uint64_t user_credential, bool ps5)
