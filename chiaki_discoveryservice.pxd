from libc.stdint cimport uint64_t

cdef extern from "chiaki/discoveryservice.h":

    ctypedef void (*ChiakiDiscoveryServiceCb)(ChiakiDiscoveryHost* hosts, size_t hosts_count, void* user)

    cdef struct chiaki_discovery_service_options_t:
        size_t hosts_max
        uint64_t host_drop_pings
        uint64_t ping_ms
        sockaddr* send_addr
        size_t send_addr_size
        ChiakiDiscoveryServiceCb cb
        void* cb_user

    ctypedef chiaki_discovery_service_options_t ChiakiDiscoveryServiceOptions

    cdef struct chiaki_discovery_service_host_discovery_info_t:
        uint64_t last_ping_index

    ctypedef chiaki_discovery_service_host_discovery_info_t ChiakiDiscoveryServiceHostDiscoveryInfo

    cdef struct chiaki_discovery_service_t:
        ChiakiLog* log
        ChiakiDiscoveryServiceOptions options
        ChiakiDiscovery discovery
        uint64_t ping_index
        ChiakiDiscoveryHost* hosts
        ChiakiDiscoveryServiceHostDiscoveryInfo* host_discovery_infos
        size_t hosts_count
        ChiakiMutex state_mutex
        ChiakiThread thread
        ChiakiBoolPredCond stop_cond

    ctypedef chiaki_discovery_service_t ChiakiDiscoveryService

    ChiakiErrorCode chiaki_discovery_service_init(ChiakiDiscoveryService* service, ChiakiDiscoveryServiceOptions* options, ChiakiLog* log)

    void chiaki_discovery_service_fini(ChiakiDiscoveryService* service)
