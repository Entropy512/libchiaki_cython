from libc.stdint cimport uint16_t, uint8_t, uint64_t, uint32_t

cdef extern from "chiaki/takion.h":

    cpdef enum chiaki_takion_message_data_type_t:
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_PROTOBUF
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_RUMBLE
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_9
        CHIAKI_TAKION_MESSAGE_DATA_TYPE_TRIGGER_EFFECTS

    ctypedef chiaki_takion_message_data_type_t ChiakiTakionMessageDataType

    cdef struct chiaki_takion_av_packet_t:
        ChiakiSeqNum16 packet_index
        ChiakiSeqNum16 frame_index
        bool uses_nalu_info_structs
        bool is_video
        bool is_haptics
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
        bool ip_dontfrag
        ChiakiTakionCallback cb
        void* cb_user
        bool enable_crypt
        bool enable_dualsense
        uint8_t protocol_version

    ctypedef chiaki_takion_connect_info_t ChiakiTakionConnectInfo

    cdef struct chiaki_takion_t:
        ChiakiLog* log
        uint8_t version
        bool enable_crypt
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
        bool enable_dualsense

    ctypedef chiaki_takion_t ChiakiTakion

    ChiakiErrorCode chiaki_takion_connect(ChiakiTakion* takion, ChiakiTakionConnectInfo* info)

    void chiaki_takion_close(ChiakiTakion* takion)

    void chiaki_takion_set_crypt(ChiakiTakion* takion, ChiakiGKCrypt* gkcrypt_local, ChiakiGKCrypt* gkcrypt_remote)

    ChiakiErrorCode chiaki_takion_packet_mac(ChiakiGKCrypt* crypt, uint8_t* buf, size_t buf_size, uint64_t key_pos, uint8_t* mac_out, uint8_t* mac_old_out)

    ChiakiErrorCode chiaki_takion_crypt_advance_key_pos(ChiakiTakion* takion, size_t data_size, uint64_t* key_pos)

    ChiakiErrorCode chiaki_takion_send_raw(ChiakiTakion* takion, const uint8_t* buf, size_t buf_size)

    ChiakiErrorCode chiaki_takion_send(ChiakiTakion* takion, uint8_t* buf, size_t buf_size, uint64_t key_pos)

    ChiakiErrorCode chiaki_takion_send_message_data(ChiakiTakion* takion, uint8_t chunk_flags, uint16_t channel, uint8_t* buf, size_t buf_size, ChiakiSeqNum32* seq_num)

    ChiakiErrorCode chiaki_takion_send_congestion(ChiakiTakion* takion, ChiakiTakionCongestionPacket* packet)

    ChiakiErrorCode chiaki_takion_send_feedback_state(ChiakiTakion* takion, ChiakiSeqNum16 seq_num, ChiakiFeedbackState* feedback_state)

    ChiakiErrorCode chiaki_takion_send_feedback_history(ChiakiTakion* takion, ChiakiSeqNum16 seq_num, uint8_t* payload, size_t payload_size)

    ChiakiErrorCode chiaki_takion_v9_av_packet_parse(ChiakiTakionAVPacket* packet, ChiakiKeyState* key_state, uint8_t* buf, size_t buf_size)

    ChiakiErrorCode chiaki_takion_v12_av_packet_parse(ChiakiTakionAVPacket* packet, ChiakiKeyState* key_state, uint8_t* buf, size_t buf_size)

    ChiakiErrorCode chiaki_takion_v7_av_packet_format_header(uint8_t* buf, size_t buf_size, size_t* header_size_out, ChiakiTakionAVPacket* packet)

    ChiakiErrorCode chiaki_takion_v7_av_packet_parse(ChiakiTakionAVPacket* packet, ChiakiKeyState* key_state, uint8_t* buf, size_t buf_size)

    void chiaki_takion_format_congestion(uint8_t* buf, ChiakiTakionCongestionPacket* packet, uint64_t key_pos)
