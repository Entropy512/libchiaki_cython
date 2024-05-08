from libc.stdint cimport uint32_t, uint8_t, uint64_t

cdef extern from "chiaki/session.h":

    const char* chiaki_rp_application_reason_string(uint32_t reason)

    const char* chiaki_rp_version_string(ChiakiTarget target)

    ChiakiTarget chiaki_rp_version_parse(const char* rp_version_str, bool is_ps5)

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
        bool ps5
        const char* host
        char regist_key[0x10]
        uint8_t morning[0x10]
        ChiakiConnectVideoProfile video_profile
        bool video_profile_auto_downgrade
        bool enable_keyboard
        bool enable_dualsense

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

    bool chiaki_quit_reason_is_error(ChiakiQuitReason reason)

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
        bool pin_incorrect

    cdef struct chiaki_event_t:
        ChiakiEventType type
        ChiakiQuitEvent quit
        ChiakiKeyboardEvent keyboard
        ChiakiRumbleEvent rumble
        ChiakiTriggerEffectsEvent trigger_effects
        _ChiakiEvent_ChiakiEvent_chiaki_event_t_login_pin_request_s login_pin_request

    ctypedef chiaki_event_t ChiakiEvent

    ctypedef void (*ChiakiEventCallback)(ChiakiEvent* event, void* user)

    ctypedef bool (*ChiakiVideoSampleCallback)(uint8_t* buf, size_t buf_size, void* user)

    cdef struct _ChiakiSession_ChiakiSession_chiaki_session_t_connect_info_s:
        bool ps5
        addrinfo* host_addrinfos
        addrinfo* host_addrinfo_selected
        char hostname[256]
        char regist_key[0x10]
        uint8_t morning[0x10]
        uint8_t did[32]
        ChiakiConnectVideoProfile video_profile
        bool video_profile_auto_downgrade
        bool enable_keyboard
        bool enable_dualsense

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
        bool should_stop
        bool ctrl_failed
        bool ctrl_session_id_received
        bool ctrl_login_pin_requested
        bool login_pin_entered
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
