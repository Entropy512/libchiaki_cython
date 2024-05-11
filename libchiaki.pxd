from libc.stdint cimport uint32_t, uint16_t, uint8_t, int8_t, int16_t, uint64_t, int32_t

cdef extern from "netinet/in.h":
    struct addrinfo:
        pass

cdef extern from "sys/socket.h":
    ctypedef uint16_t sa_family_t

    struct sockaddr:
        sa_family_t sa_family
        char sa_data[14]

cdef extern from "netdb.h":
    int32_t getaddrinfo(const char *node,
                    const char *service,
                    const addrinfo *hints,
                    addrinfo **res)

cdef extern from "libchiaki.h":

    ctypedef uint32_t chiaki_unaligned_uint32_t

    ctypedef uint16_t chiaki_unaligned_uint16_t

    ctypedef enum ChiakiErrorCode:
        CHIAKI_ERR_SUCCESS
        CHIAKI_ERR_UNKNOWN
        CHIAKI_ERR_PARSE_ADDR
        CHIAKI_ERR_THREAD
        CHIAKI_ERR_MEMORY
        CHIAKI_ERR_OVERFLOW
        CHIAKI_ERR_NETWORK
        CHIAKI_ERR_CONNECTION_REFUSED
        CHIAKI_ERR_HOST_DOWN
        CHIAKI_ERR_HOST_UNREACH
        CHIAKI_ERR_DISCONNECTED
        CHIAKI_ERR_INVALID_DATA
        CHIAKI_ERR_BUF_TOO_SMALL
        CHIAKI_ERR_MUTEX_LOCKED
        CHIAKI_ERR_CANCELED
        CHIAKI_ERR_TIMEOUT
        CHIAKI_ERR_INVALID_RESPONSE
        CHIAKI_ERR_INVALID_MAC
        CHIAKI_ERR_UNINITIALIZED
        CHIAKI_ERR_FEC_FAILED
        CHIAKI_ERR_VERSION_MISMATCH

    const char* chiaki_error_string(ChiakiErrorCode code)

    void* chiaki_aligned_alloc(size_t alignment, size_t size)

    void chiaki_aligned_free(void* ptr)

    ctypedef enum ChiakiTarget:
        CHIAKI_TARGET_PS4_UNKNOWN
        CHIAKI_TARGET_PS4_8
        CHIAKI_TARGET_PS4_9
        CHIAKI_TARGET_PS4_10
        CHIAKI_TARGET_PS5_UNKNOWN
        CHIAKI_TARGET_PS5_1

    bint  chiaki_target_is_unknown(ChiakiTarget target)

    bint  chiaki_target_is_ps5(ChiakiTarget target)

    ChiakiErrorCode chiaki_lib_init()

    ctypedef enum ChiakiCodec:
        CHIAKI_CODEC_H264
        CHIAKI_CODEC_H265
        CHIAKI_CODEC_H265_HDR

    bint  chiaki_codec_is_h265(ChiakiCodec codec)

    bint  chiaki_codec_is_hdr(ChiakiCodec codec)

    const char* chiaki_codec_name(ChiakiCodec codec)

    ctypedef enum ChiakiLogLevel:
        CHIAKI_LOG_DEBUG
        CHIAKI_LOG_VERBOSE
        CHIAKI_LOG_INFO
        CHIAKI_LOG_WARNING
        CHIAKI_LOG_ERROR

    char chiaki_log_level_char(ChiakiLogLevel level)

    ctypedef void (*ChiakiLogCb)(ChiakiLogLevel level, const char* msg, void* user)

    cdef struct chiaki_log_t:
        uint32_t level_mask
        ChiakiLogCb cb
        void* user

    ctypedef chiaki_log_t ChiakiLog

    void chiaki_log_init(ChiakiLog* log, uint32_t level_mask, ChiakiLogCb cb, void* user)

    void chiaki_log_cb_print(ChiakiLogLevel level, const char* msg, void* user)

    void chiaki_log(ChiakiLog* log, ChiakiLogLevel level, const char* fmt, ...)

    void chiaki_log_hexdump(ChiakiLog* log, ChiakiLogLevel level, const uint8_t* buf, size_t buf_size)

    void chiaki_log_hexdump_raw(ChiakiLog* log, ChiakiLogLevel level, const uint8_t* buf, size_t buf_size)

    cdef struct chiaki_log_sniffer_t:
        ChiakiLog* forward_log
        ChiakiLog sniff_log
        uint32_t sniff_level_mask
        char* buf
        size_t buf_len

    ctypedef chiaki_log_sniffer_t ChiakiLogSniffer

    void chiaki_log_sniffer_init(ChiakiLogSniffer* sniffer, uint32_t level_mask, ChiakiLog* forward_log)

    void chiaki_log_sniffer_fini(ChiakiLogSniffer* sniffer)

    ChiakiLog* chiaki_log_sniffer_get_log(ChiakiLogSniffer* sniffer)

    const char* chiaki_log_sniffer_get_buffer(ChiakiLogSniffer* sniffer)

    cpdef enum chiaki_controller_button_t:
        CHIAKI_CONTROLLER_BUTTON_CROSS
        CHIAKI_CONTROLLER_BUTTON_MOON
        CHIAKI_CONTROLLER_BUTTON_BOX
        CHIAKI_CONTROLLER_BUTTON_PYRAMID
        CHIAKI_CONTROLLER_BUTTON_DPAD_LEFT
        CHIAKI_CONTROLLER_BUTTON_DPAD_RIGHT
        CHIAKI_CONTROLLER_BUTTON_DPAD_UP
        CHIAKI_CONTROLLER_BUTTON_DPAD_DOWN
        CHIAKI_CONTROLLER_BUTTON_L1
        CHIAKI_CONTROLLER_BUTTON_R1
        CHIAKI_CONTROLLER_BUTTON_L3
        CHIAKI_CONTROLLER_BUTTON_R3
        CHIAKI_CONTROLLER_BUTTON_OPTIONS
        CHIAKI_CONTROLLER_BUTTON_SHARE
        CHIAKI_CONTROLLER_BUTTON_TOUCHPAD
        CHIAKI_CONTROLLER_BUTTON_PS

    ctypedef chiaki_controller_button_t ChiakiControllerButton

    cpdef enum chiaki_controller_analog_button_t:
        CHIAKI_CONTROLLER_ANALOG_BUTTON_L2
        CHIAKI_CONTROLLER_ANALOG_BUTTON_R2

    ctypedef chiaki_controller_analog_button_t ChiakiControllerAnalogButton

    cdef struct chiaki_controller_touch_t:
        uint16_t x
        uint16_t y
        int8_t id

    ctypedef chiaki_controller_touch_t ChiakiControllerTouch

    cdef struct chiaki_controller_state_t:
        uint32_t buttons
        uint8_t l2_state
        uint8_t r2_state
        int16_t left_x
        int16_t left_y
        int16_t right_x
        int16_t right_y
        uint8_t touch_id_next
        ChiakiControllerTouch touches[2]
        float gyro_x
        float gyro_y
        float gyro_z
        float accel_x
        float accel_y
        float accel_z
        float orient_x
        float orient_y
        float orient_z
        float orient_w

    ctypedef chiaki_controller_state_t ChiakiControllerState

    void chiaki_controller_state_set_idle(ChiakiControllerState* state)

    int8_t chiaki_controller_state_start_touch(ChiakiControllerState* state, uint16_t x, uint16_t y)

    void chiaki_controller_state_stop_touch(ChiakiControllerState* state, uint8_t id)

    void chiaki_controller_state_set_touch_pos(ChiakiControllerState* state, uint8_t id, uint16_t x, uint16_t y)

    bint  chiaki_controller_state_equals(ChiakiControllerState* a, ChiakiControllerState* b)

    void chiaki_controller_state_or(ChiakiControllerState* out, ChiakiControllerState* a, ChiakiControllerState* b)

    cdef struct chiaki_orientation_t:
        float x
        float y
        float z
        float w

    ctypedef chiaki_orientation_t ChiakiOrientation

    void chiaki_orientation_init(ChiakiOrientation* orient)

    void chiaki_orientation_update(ChiakiOrientation* orient, float gx, float gy, float gz, float ax, float ay, float az, float beta, float time_step_sec)

    cdef struct chiaki_orientation_tracker_t:
        float gyro_x
        float gyro_y
        float gyro_z
        float accel_x
        float accel_y
        float accel_z
        ChiakiOrientation orient
        uint32_t timestamp
        uint64_t sample_index

    ctypedef chiaki_orientation_tracker_t ChiakiOrientationTracker

    void chiaki_orientation_tracker_init(ChiakiOrientationTracker* tracker)

    void chiaki_orientation_tracker_update(ChiakiOrientationTracker* tracker, float gx, float gy, float gz, float ax, float ay, float az, uint32_t timestamp_us)

    void chiaki_orientation_tracker_apply_to_controller_state(ChiakiOrientationTracker* tracker, ChiakiControllerState* state)

    ctypedef uint16_t ChiakiSeqNum16

    bint  chiaki_seq_num_16_lt(ChiakiSeqNum16 a, ChiakiSeqNum16 b)

    bint  chiaki_seq_num_16_gt(ChiakiSeqNum16 a, ChiakiSeqNum16 b)

    ctypedef uint32_t ChiakiSeqNum32

    bint  chiaki_seq_num_32_lt(ChiakiSeqNum32 a, ChiakiSeqNum32 b)

    bint  chiaki_seq_num_32_gt(ChiakiSeqNum32 a, ChiakiSeqNum32 b)

    # https://groups.google.com/g/cython-users/c/kqUBhXwqHSY
    cdef struct pthread_t:
        pass

    cdef struct pthread_mutex_t:
        pass

    cdef struct pthread_cond_t:
        pass

    cdef struct chiaki_thread_t:
        pthread_t thread

    ctypedef chiaki_thread_t ChiakiThread

    cdef struct chiaki_mutex_t:
        pthread_mutex_t mutex

    ctypedef chiaki_mutex_t ChiakiMutex

    cdef struct chiaki_cond_t:
        pthread_cond_t cond

    ctypedef chiaki_cond_t ChiakiCond

    cdef struct chiaki_bool_pred_cond_t:
        ChiakiCond cond
        ChiakiMutex mutex
        bint  pred

    ctypedef chiaki_bool_pred_cond_t ChiakiBoolPredCond

    cdef struct chiaki_stop_pipe_t:
        int fds[2]

    ctypedef chiaki_stop_pipe_t ChiakiStopPipe

    ctypedef int chiaki_socket_t

    char* CHIAKI_DISCOVERY_PROTOCOL_VERSION_PS4
    char* CHIAKI_DISCOVERY_PROTOCOL_VERSION_PS5

    uint16_t CHIAKI_DISCOVERY_PORT_PS4
    uint16_t CHIAKI_DISCOVERY_PORT_PS5

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

    cdef struct chiaki_discovery_t:
        ChiakiLog* log
        chiaki_socket_t socket
        sockaddr local_addr

    ctypedef chiaki_discovery_t ChiakiDiscovery

    const char *chiaki_discovery_host_state_string(ChiakiDiscoveryHostState state)

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

    ChiakiErrorCode chiaki_discovery_wakeup(ChiakiLog *log, ChiakiDiscovery *discovery, const char *host, uint64_t user_credential, bint ps5);

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

    cdef struct chiaki_audio_header_t:
        uint8_t channels
        uint8_t bits
        uint32_t rate
        uint32_t frame_size
        uint32_t unknown

    ctypedef chiaki_audio_header_t ChiakiAudioHeader

    cdef struct chiaki_packet_stats_t:
        ChiakiMutex mutex
        uint64_t gen_received
        uint64_t gen_lost
        ChiakiSeqNum16 seq_min
        ChiakiSeqNum16 seq_max
        uint64_t seq_received

    ctypedef chiaki_packet_stats_t ChiakiPacketStats

    ctypedef void (*ChiakiAudioSinkHeader)(ChiakiAudioHeader* header, void* user)

    ctypedef void (*ChiakiAudioSinkFrame)(uint8_t* buf, size_t buf_size, void* user)

    cdef struct chiaki_audio_sink_t:
        void* user
        ChiakiAudioSinkHeader header_cb
        ChiakiAudioSinkFrame frame_cb

    ctypedef chiaki_audio_sink_t ChiakiAudioSink

    cdef struct chiaki_audio_receiver_t:
        chiaki_session_t* session
        ChiakiLog* log
        ChiakiMutex mutex
        ChiakiSeqNum16 frame_index_prev
        bint  frame_index_startup
        ChiakiPacketStats* packet_stats

    ctypedef chiaki_audio_receiver_t ChiakiAudioReceiver

    cdef struct chiaki_rpcrypt_t:
        ChiakiTarget target
        uint8_t bright[0x10]
        uint8_t ambassador[0x10]

    ctypedef chiaki_rpcrypt_t ChiakiRPCrypt

    cdef struct ec_group_st:
        pass

    cdef struct ec_key_st:
        pass

    cdef struct chiaki_ecdh_t:
        ec_group_st* group
        ec_key_st* key_local

    ctypedef chiaki_ecdh_t ChiakiECDH

    ctypedef chiaki_ctrl_message_queue_t ChiakiCtrlMessageQueue

    cdef struct chiaki_ctrl_message_queue_t:
        ChiakiCtrlMessageQueue* next
        uint16_t type
        uint8_t* payload
        size_t payload_size

    cdef struct chiaki_ctrl_t:
        chiaki_session_t* session
        ChiakiThread thread
        bint  should_stop
        bint  login_pin_entered
        uint8_t* login_pin
        size_t login_pin_size
        ChiakiCtrlMessageQueue* msg_queue
        ChiakiStopPipe notif_pipe
        ChiakiMutex notif_mutex
        bint  login_pin_requested
        chiaki_socket_t sock
        uint8_t recv_buf[512]
        size_t recv_buf_size
        uint64_t crypt_counter_local
        uint64_t crypt_counter_remote
        uint32_t keyboard_text_counter

    ctypedef chiaki_ctrl_t ChiakiCtrl

    cdef struct chiaki_key_state_t:
        uint64_t prev

    ctypedef chiaki_key_state_t ChiakiKeyState

    cdef struct chiaki_gkcrypt_t:
        uint8_t index
        uint8_t* key_buf
        size_t key_buf_size
        size_t key_buf_populated
        uint64_t key_buf_key_pos_min
        size_t key_buf_start_offset
        uint64_t last_key_pos
        bint  key_buf_thread_stop
        ChiakiMutex key_buf_mutex
        ChiakiCond key_buf_cond
        ChiakiThread key_buf_thread
        uint8_t iv[0x10]
        uint8_t key_base[0x10]
        uint8_t key_gmac_base[0x10]
        uint8_t key_gmac_current[0x10]
        uint64_t key_gmac_index_current
        ChiakiLog* log

    ctypedef chiaki_gkcrypt_t ChiakiGKCrypt

    cpdef enum chiaki_reorder_queue_drop_strategy_t:
        CHIAKI_REORDER_QUEUE_DROP_STRATEGY_BEGIN
        CHIAKI_REORDER_QUEUE_DROP_STRATEGY_END

    ctypedef chiaki_reorder_queue_drop_strategy_t ChiakiReorderQueueDropStrategy

    cdef struct chiaki_reorder_queue_entry_t:
        void* user
        bint  set

    ctypedef chiaki_reorder_queue_entry_t ChiakiReorderQueueEntry

    ctypedef void (*ChiakiReorderQueueDropCb)(uint64_t seq_num, void* elem_user, void* cb_user)

    ctypedef bint  (*ChiakiReorderQueueSeqNumGt)(uint64_t a, uint64_t b)

    ctypedef bint  (*ChiakiReorderQueueSeqNumLt)(uint64_t a, uint64_t b)

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

    cdef struct chiaki_takion_send_buffer_packet_t:
        ChiakiSeqNum32 seq_num
        uint64_t tries
        uint64_t last_send_ms
        uint8_t* buf
        size_t buf_size

    ctypedef chiaki_takion_send_buffer_packet_t ChiakiTakionSendBufferPacket

    ctypedef chiaki_takion_t ChiakiTakion

    cdef struct chiaki_takion_send_buffer_t:
        ChiakiLog* log
        ChiakiTakion* takion
        ChiakiTakionSendBufferPacket* packets
        size_t packets_size
        size_t packets_count
        ChiakiMutex mutex
        ChiakiCond cond
        bint  should_stop
        ChiakiThread thread

    ctypedef chiaki_takion_send_buffer_t ChiakiTakionSendBuffer

    cpdef enum chiaki_takion_message_data_type_t:
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_PROTOBUF
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_RUMBLE
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_9
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_TRIGGER_EFFECTS

    ctypedef chiaki_takion_message_data_type_t ChiakiTakionMessageDataType

    cdef struct chiaki_takion_av_packet_t:
        ChiakiSeqNum16 packet_index
        ChiakiSeqNum16 frame_index
        bint  uses_nalu_info_structs
        bint  is_video
        bint  is_haptics
        ChiakiSeqNum16 unit_index
        uint16_t units_in_frame_total
        uint16_t units_in_frame_fec
        uint8_t codec
        uint16_t word_at_0x18
        uint8_t adaptive_stream_index
        uint8_t byte_at_0x2c
        uint64_t key_pos
        uint8_t* data
        size_t data_size

    ctypedef chiaki_takion_av_packet_t ChiakiTakionAVPacket

    uint8_t chiaki_takion_av_packet_audio_unit_size(ChiakiTakionAVPacket* packet)

    uint8_t chiaki_takion_av_packet_audio_source_units_count(ChiakiTakionAVPacket* packet)

    uint8_t chiaki_takion_av_packet_audio_fec_units_count(ChiakiTakionAVPacket* packet)

    ctypedef ChiakiErrorCode (*ChiakiTakionAVPacketParse)(ChiakiTakionAVPacket* packet, ChiakiKeyState* key_state, uint8_t* buf, size_t buf_size)

    cdef struct chiaki_takion_congestion_packet_t:
        uint16_t word_0
        uint16_t received
        uint16_t lost

    ctypedef chiaki_takion_congestion_packet_t ChiakiTakionCongestionPacket

    ctypedef enum ChiakiTakionEventType:
        CHIAKI_TAKION_EVENT_TYPE_CONNECTED
        CHIAKI_TAKION_EVENT_TYPE_DISCONNECT
        CHIAKI_TAKION_EVENT_TYPE_DATA
        CHIAKI_TAKION_EVENT_TYPE_DATA_ACK
        CHIAKI_TAKION_EVENT_TYPE_AV

    cdef struct _ChiakiTakionEvent_ChiakiTakionEvent_chiaki_takion_event_t_data_s:
        ChiakiTakionMessageDataType data_type
        uint8_t* buf
        size_t buf_size

    cdef struct _ChiakiTakionEvent_ChiakiTakionEvent_chiaki_takion_event_t_data_ack_s:
        ChiakiSeqNum32 seq_num

    cdef struct chiaki_takion_event_t:
        ChiakiTakionEventType type
        _ChiakiTakionEvent_ChiakiTakionEvent_chiaki_takion_event_t_data_s data
        _ChiakiTakionEvent_ChiakiTakionEvent_chiaki_takion_event_t_data_ack_s data_ack
        ChiakiTakionAVPacket* av

    ctypedef chiaki_takion_event_t ChiakiTakionEvent

    ctypedef void (*ChiakiTakionCallback)(ChiakiTakionEvent* event, void* user)

    cdef struct chiaki_takion_connect_info_t:
        ChiakiLog* log
        sockaddr* sa
        size_t sa_len
        bint  ip_dontfrag
        ChiakiTakionCallback cb
        void* cb_user
        bint  enable_crypt
        bint  enable_dualsense
        uint8_t protocol_version

    ctypedef chiaki_takion_connect_info_t ChiakiTakionConnectInfo

    cdef struct chiaki_takion_postponed_packet_t:
        uint8_t* buf
        size_t buf_size

    ctypedef chiaki_takion_postponed_packet_t ChiakiTakionPostponedPacket

    cdef struct chiaki_takion_t:
        ChiakiLog* log
        uint8_t version
        bint  enable_crypt
        chiaki_takion_postponed_packet_t* postponed_packets
        size_t postponed_packets_size
        size_t postponed_packets_count
        ChiakiGKCrypt* gkcrypt_local
        uint64_t key_pos_local
        ChiakiMutex gkcrypt_local_mutex
        ChiakiGKCrypt* gkcrypt_remote
        ChiakiReorderQueue data_queue
        ChiakiTakionSendBuffer send_buffer
        ChiakiTakionCallback cb
        void* cb_user
        chiaki_socket_t sock
        ChiakiThread thread
        ChiakiStopPipe stop_pipe
        uint32_t tag_local
        uint32_t tag_remote
        ChiakiSeqNum32 seq_num_local
        ChiakiMutex seq_num_local_mutex
        uint32_t a_rwnd
        ChiakiTakionAVPacketParse av_packet_parse
        ChiakiKeyState key_state
        bint  enable_dualsense

    cdef struct chiaki_video_profile_t:
        unsigned int width
        unsigned int height
        size_t header_sz
        uint8_t* header

    ctypedef chiaki_video_profile_t ChiakiVideoProfile

    cdef struct chiaki_stream_stats_t:
        uint64_t frames
        uint64_t bytes

    ctypedef chiaki_stream_stats_t ChiakiStreamStats

    cdef struct chiaki_frame_unit_t:
        pass

    ctypedef chiaki_frame_unit_t ChiakiFrameUnit

    cdef struct chiaki_frame_processor_t:
        ChiakiLog* log
        uint8_t* frame_buf
        size_t frame_buf_size
        size_t buf_size_per_unit
        size_t buf_stride_per_unit
        unsigned int units_source_expected
        unsigned int units_fec_expected
        unsigned int units_source_received
        unsigned int units_fec_received
        ChiakiFrameUnit* unit_slots
        size_t unit_slots_size
        bint  flushed
        ChiakiStreamStats stream_stats

    ctypedef chiaki_frame_processor_t ChiakiFrameProcessor

    cdef struct chiaki_video_receiver_t:
        chiaki_session_t* session
        ChiakiLog* log
        ChiakiVideoProfile profiles[8]
        size_t profiles_count
        int profile_cur
        int32_t frame_index_cur
        int32_t frame_index_prev
        int32_t frame_index_prev_complete
        ChiakiFrameProcessor frame_processor
        ChiakiPacketStats* packet_stats

    ctypedef chiaki_video_receiver_t ChiakiVideoReceiver

    cdef struct chiaki_feedback_state_t:
        float gyro_x
        float gyro_y
        float gyro_z
        float accel_x
        float accel_y
        float accel_z
        float orient_x
        float orient_y
        float orient_z
        float orient_w
        int16_t left_x
        int16_t left_y
        int16_t right_x
        int16_t right_y

    ctypedef chiaki_feedback_state_t ChiakiFeedbackState

    cdef struct chiaki_feedback_history_event_t:
        uint8_t buf[0x5]
        size_t len

    ctypedef chiaki_feedback_history_event_t ChiakiFeedbackHistoryEvent

    cdef struct chiaki_feedback_history_buffer_t:
        ChiakiFeedbackHistoryEvent* events
        size_t size
        size_t begin
        size_t len

    ctypedef chiaki_feedback_history_buffer_t ChiakiFeedbackHistoryBuffer

    cdef struct chiaki_feedback_sender_t:
        ChiakiLog* log
        ChiakiTakion* takion
        ChiakiThread thread
        ChiakiSeqNum16 state_seq_num
        ChiakiSeqNum16 history_seq_num
        ChiakiFeedbackHistoryBuffer history_buf
        bint  should_stop
        ChiakiControllerState controller_state_prev
        ChiakiControllerState controller_state
        bint  controller_state_changed
        ChiakiMutex state_mutex
        ChiakiCond state_cond

    ctypedef chiaki_feedback_sender_t ChiakiFeedbackSender

    cdef struct chiaki_stream_connection_t:
        chiaki_session_t* session
        ChiakiLog* log
        ChiakiTakion takion
        uint8_t* ecdh_secret
        ChiakiGKCrypt* gkcrypt_local
        ChiakiGKCrypt* gkcrypt_remote
        ChiakiPacketStats packet_stats
        ChiakiAudioReceiver* audio_receiver
        ChiakiVideoReceiver* video_receiver
        ChiakiAudioReceiver* haptics_receiver
        ChiakiFeedbackSender feedback_sender
        bint  feedback_sender_active
        ChiakiMutex feedback_sender_mutex
        ChiakiCond state_cond
        ChiakiMutex state_mutex
        int state
        bint  state_finished
        bint  state_failed
        bint  should_stop
        bint  remote_disconnected
        char* remote_disconnect_reason

    ctypedef chiaki_stream_connection_t ChiakiStreamConnection

    const char* chiaki_rp_application_reason_string(uint32_t reason)

    const char* chiaki_rp_version_string(ChiakiTarget target)

    ChiakiTarget chiaki_rp_version_parse(const char* rp_version_str, bint  is_ps5)

    cdef struct chiaki_connect_video_profile_t:
        unsigned int width
        unsigned int height
        unsigned int max_fps
        unsigned int bitrate
        ChiakiCodec codec

    ctypedef chiaki_connect_video_profile_t ChiakiConnectVideoProfile

    ctypedef enum ChiakiVideoResolutionPreset:
        CHIAKI_VIDEO_RESOLUTION_PRESET_360p
        CHIAKI_VIDEO_RESOLUTION_PRESET_540p
        CHIAKI_VIDEO_RESOLUTION_PRESET_720p
        CHIAKI_VIDEO_RESOLUTION_PRESET_1080p

    ctypedef enum ChiakiVideoFPSPreset:
        CHIAKI_VIDEO_FPS_PRESET_30
        CHIAKI_VIDEO_FPS_PRESET_60

    void chiaki_connect_video_profile_preset(ChiakiConnectVideoProfile* profile, ChiakiVideoResolutionPreset resolution, ChiakiVideoFPSPreset fps)

    cdef struct chiaki_connect_info_t:
        bint  ps5
        const char* host
        char regist_key[0x10]
        uint8_t morning[0x10]
        ChiakiConnectVideoProfile video_profile
        bint  video_profile_auto_downgrade
        bint  enable_keyboard
        bint  enable_dualsense

    ctypedef chiaki_connect_info_t ChiakiConnectInfo

    ctypedef enum ChiakiQuitReason:
        CHIAKI_QUIT_REASON_NONE
        CHIAKI_QUIT_REASON_STOPPED
        CHIAKI_QUIT_REASON_SESSION_REQUEST_UNKNOWN
        CHIAKI_QUIT_REASON_SESSION_REQUEST_CONNECTION_REFUSED
        CHIAKI_QUIT_REASON_SESSION_REQUEST_RP_IN_USE
        CHIAKI_QUIT_REASON_SESSION_REQUEST_RP_CRASH
        CHIAKI_QUIT_REASON_SESSION_REQUEST_RP_VERSION_MISMATCH
        CHIAKI_QUIT_REASON_CTRL_UNKNOWN
        CHIAKI_QUIT_REASON_CTRL_CONNECT_FAILED
        CHIAKI_QUIT_REASON_CTRL_CONNECTION_REFUSED
        CHIAKI_QUIT_REASON_STREAM_CONNECTION_UNKNOWN
        CHIAKI_QUIT_REASON_STREAM_CONNECTION_REMOTE_DISCONNECTED
        CHIAKI_QUIT_REASON_STREAM_CONNECTION_REMOTE_SHUTDOWN

    const char* chiaki_quit_reason_string(ChiakiQuitReason reason)

    bint  chiaki_quit_reason_is_error(ChiakiQuitReason reason)

    cdef struct chiaki_quit_event_t:
        ChiakiQuitReason reason
        const char* reason_str

    ctypedef chiaki_quit_event_t ChiakiQuitEvent

    cdef struct chiaki_keyboard_event_t:
        const char* text_str

    ctypedef chiaki_keyboard_event_t ChiakiKeyboardEvent

    cdef struct chiaki_audio_stream_info_event_t:
        ChiakiAudioHeader audio_header

    ctypedef chiaki_audio_stream_info_event_t ChiakiAudioStreamInfoEvent

    cdef struct chiaki_rumble_event_t:
        uint8_t unknown
        uint8_t left
        uint8_t right

    ctypedef chiaki_rumble_event_t ChiakiRumbleEvent

    cdef struct chiaki_trigger_effects_event_t:
        uint8_t type_left
        uint8_t type_right
        uint8_t left[10]
        uint8_t right[10]

    ctypedef chiaki_trigger_effects_event_t ChiakiTriggerEffectsEvent

    ctypedef enum ChiakiEventType:
        CHIAKI_EVENT_CONNECTED
        CHIAKI_EVENT_LOGIN_PIN_REQUEST
        CHIAKI_EVENT_KEYBOARD_OPEN
        CHIAKI_EVENT_KEYBOARD_TEXT_CHANGE
        CHIAKI_EVENT_KEYBOARD_REMOTE_CLOSE
        CHIAKI_EVENT_RUMBLE
        CHIAKI_EVENT_QUIT
        CHIAKI_EVENT_TRIGGER_EFFECTS

    cdef struct _ChiakiEvent_ChiakiEvent_chiaki_event_t_login_pin_request_s:
        bint  pin_incorrect

    cdef struct chiaki_event_t:
        ChiakiEventType type
        ChiakiQuitEvent quit
        ChiakiKeyboardEvent keyboard
        ChiakiRumbleEvent rumble
        ChiakiTriggerEffectsEvent trigger_effects
        _ChiakiEvent_ChiakiEvent_chiaki_event_t_login_pin_request_s login_pin_request

    ctypedef chiaki_event_t ChiakiEvent

    ctypedef void (*ChiakiEventCallback)(ChiakiEvent* event, void* user)

    ctypedef bint  (*ChiakiVideoSampleCallback)(uint8_t* buf, size_t buf_size, void* user)

    cdef struct _ChiakiSession_ChiakiSession_chiaki_session_t_connect_info_s:
        bint  ps5
        addrinfo* host_addrinfos
        addrinfo* host_addrinfo_selected
        char hostname[256]
        char regist_key[0x10]
        uint8_t morning[0x10]
        uint8_t did[32]
        ChiakiConnectVideoProfile video_profile
        bint  video_profile_auto_downgrade
        bint  enable_keyboard
        bint  enable_dualsense

    cdef struct chiaki_session_t:
        _ChiakiSession_ChiakiSession_chiaki_session_t_connect_info_s connect_info
        ChiakiTarget target
        uint8_t nonce[0x10]
        ChiakiRPCrypt rpcrypt
        char session_id[80]
        uint8_t handshake_key[0x10]
        uint32_t mtu_in
        uint32_t mtu_out
        uint64_t rtt_us
        ChiakiECDH ecdh
        ChiakiQuitReason quit_reason
        char* quit_reason_str
        ChiakiEventCallback event_cb
        void* event_cb_user
        ChiakiVideoSampleCallback video_sample_cb
        void* video_sample_cb_user
        ChiakiAudioSink audio_sink
        ChiakiAudioSink haptics_sink
        ChiakiThread session_thread
        ChiakiCond state_cond
        ChiakiMutex state_mutex
        ChiakiStopPipe stop_pipe
        bint  should_stop
        bint  ctrl_failed
        bint  ctrl_session_id_received
        bint  ctrl_login_pin_requested
        bint  login_pin_entered
        uint8_t* login_pin
        size_t login_pin_size
        ChiakiCtrl ctrl
        ChiakiLog* log
        ChiakiStreamConnection stream_connection
        ChiakiControllerState controller_state

    ctypedef chiaki_session_t ChiakiSession

    ChiakiErrorCode chiaki_session_init(ChiakiSession* session, ChiakiConnectInfo* connect_info, ChiakiLog* log)

    void chiaki_session_fini(ChiakiSession* session)

    ChiakiErrorCode chiaki_session_start(ChiakiSession* session)

    ChiakiErrorCode chiaki_session_stop(ChiakiSession* session)

    ChiakiErrorCode chiaki_session_join(ChiakiSession* session)

    ChiakiErrorCode chiaki_session_set_controller_state(ChiakiSession* session, ChiakiControllerState* state)

    ChiakiErrorCode chiaki_session_set_login_pin(ChiakiSession* session, const uint8_t* pin, size_t pin_size)

    ChiakiErrorCode chiaki_session_goto_bed(ChiakiSession* session)

    ChiakiErrorCode chiaki_session_keyboard_set_text(ChiakiSession* session, const char* text)

    ChiakiErrorCode chiaki_session_keyboard_reject(ChiakiSession* session)

    ChiakiErrorCode chiaki_session_keyboard_accept(ChiakiSession* session)

    void chiaki_session_set_event_cb(ChiakiSession* session, ChiakiEventCallback cb, void* user)

    void chiaki_session_set_video_sample_cb(ChiakiSession* session, ChiakiVideoSampleCallback cb, void* user)

    void chiaki_session_set_audio_sink(ChiakiSession* session, ChiakiAudioSink* sink)

    void chiaki_session_set_haptics_sink(ChiakiSession* session, ChiakiAudioSink* sink)

    cdef struct chiaki_regist_info_t:
        ChiakiTarget target
        const char* host
        bint  broadcast
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
