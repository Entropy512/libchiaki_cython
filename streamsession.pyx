from libchiaki cimport *
#from libc.string cimport memset, memcpy
from libc.stdio cimport printf
from libc.stdint cimport uint8_t

cpdef enum JoyButtons:
    CROSS 		= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_CROSS,
    MOON 		= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_MOON,
    BOX 		= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_BOX,
    PYRAMID 	= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_PYRAMID,
    DPAD_LEFT 	= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_DPAD_LEFT,
    DPAD_RIGHT = ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_DPAD_RIGHT,
    DPAD_UP 	= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_DPAD_UP,
    DPAD_DOWN 	= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_DPAD_DOWN,
    L1 		= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_L1,
    R1 		= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_R1,
    L3			= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_L3,
    R3			= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_R3,
    OPTIONS 	= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_OPTIONS,
    SHARE 		= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_SHARE,
    TOUCHPAD	= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_TOUCHPAD,
    PS			= ChiakiControllerButton.CHIAKI_CONTROLLER_BUTTON_PS

cpdef enum JoyAxes:
    RX,
    RY,
    RZ,
    LX,
    LY,
    LZ

cdef class ChiakiStreamSession:
    cdef ChiakiLog log
    cdef ChiakiSession session
    cdef ChiakiTarget target
    cdef bint is_ps5
    cdef ChiakiControllerState controller_state
    cdef ChiakiControllerState keyboard_state
    cdef char* regkey
    cdef char* rpkey
    cdef char* host
    cdef public bint connected

    def __cinit__(self, host=None, regkey = None, rpkey = None):
        self.regkey = <char*> regkey
        self.rpkey = <char*> rpkey
        temphost = host.encode('UTF-8')
        self.host = <char *> temphost

        self.connected = False
        self.target = CHIAKI_TARGET_PS5_1
        self.is_ps5 = True #FIXME:  Support PS4s at some point.  But these controller-only remoteplay hax are primarily for PS5

        chiaki_log_init(&self.log, CHIAKI_LOG_ERROR, chiaki_log_cb_print, NULL)

        chiaki_controller_state_set_idle(&self.controller_state)
    
        chiaki_controller_state_set_idle(&self.keyboard_state)

        cdef ChiakiAudioSink dummy_sink
        dummy_sink.user = &self.log
        dummy_sink.frame_cb = self.dummy_frame_cb
        dummy_sink.header_cb = self.dummy_header_cb
        chiaki_session_set_audio_sink(&self.session, &dummy_sink)

        cdef ChiakiAudioSink haptics_sink
        haptics_sink.user = <void*> self
        haptics_sink.frame_cb = self.haptics_frame_cb
        chiaki_session_set_haptics_sink(&self.session, &haptics_sink)

        cdef ChiakiConnectVideoProfile vid_profile
        chiaki_connect_video_profile_preset(&vid_profile, CHIAKI_VIDEO_RESOLUTION_PRESET_360p, CHIAKI_VIDEO_FPS_PRESET_30)

        cdef ChiakiConnectInfo connect_info
        connect_info.ps5 = chiaki_target_is_ps5(self.target)
        connect_info.host = self.host
        connect_info.enable_keyboard = False #Pretty sure this means disabling sending of keyboard events to the PS5, not "do not handle local keyboard"
        connect_info.video_profile = vid_profile
        connect_info.video_profile_auto_downgrade = True
        connect_info.morning = self.rpkey
        connect_info.regist_key = self.regkey
        connect_info.enable_dualsense = True

        err = chiaki_session_init(&self.session, &connect_info, &self.log)
        if(err != CHIAKI_ERR_SUCCESS):
            raise Exception("Chiaki Session Init failed: " + chiaki_error_string(err))

        chiaki_session_set_event_cb(&self.session, <ChiakiEventCallback> self.event_cb, <void*> self)

    def __del__(self):
        chiaki_session_join(&self.session)
        chiaki_session_fini(&self.session)

    cpdef void Start(self):
        cdef ChiakiErrorCode err = chiaki_session_start(&self.session)
        if(err != CHIAKI_ERR_SUCCESS):
            chiaki_session_fini(&self.session)
            raise Exception("Session start failed")
        else:
            printf("Session start succeeded!\n")

    cpdef void Stop(self):
        chiaki_session_stop(&self.session)

    cpdef void GoToBed(self):
        chiaki_session_goto_bed(&self.session)

    def HandleAxisEvent(self, axis, value):
        if(axis == JoyAxes.RX):
            self.controller_state.right_x = value
        elif(axis == JoyAxes.RY):
            self.controller_state.right_y = value
        elif(axis == JoyAxes.RZ):
            self.controller_state.r2_state = value
        elif(axis == JoyAxes.LX):
            self.controller_state.left_x = value
        elif(axis == JoyAxes.LY):
            self.controller_state.left_y = value
        elif(axis == JoyAxes.LZ):
            self.controller_state.l2_state = value

        self.SendFeedbackState()

    def HandleButtonEvent(self, key, pressed, sendImm = True):
        cdef ChiakiControllerButton button = key
        if(pressed):
            self.keyboard_state.buttons |= button
        else:
            self.keyboard_state.buttons &= ~button

        if(sendImm):
            self.SendFeedbackState()

    cdef void SendFeedbackState(self):
        cdef ChiakiControllerState state
        chiaki_controller_state_set_idle(&state)
        chiaki_controller_state_or(&state, &state, &self.controller_state)
        chiaki_controller_state_or(&state, &state, &self.keyboard_state)
        chiaki_session_set_controller_state(&self.session, &state)

    @staticmethod
    cdef void haptics_frame_cb(uint8_t *buf, size_t buf_size, void *selfref) noexcept:
        self = <ChiakiStreamSession> selfref
        printf("Haptics callback received, length %zu\n", buf_size)

    @staticmethod
    cdef void event_cb(ChiakiEvent *event, void *selfref) noexcept:
        self = <ChiakiStreamSession> selfref
        printf("Event callback received\n")
        if(event.type == CHIAKI_EVENT_CONNECTED):
            printf("Connected event received\n")
            self.connected = True
        elif(event.type == CHIAKI_EVENT_QUIT):
            self.connected = False
            printf("Session quit, reason: %s\n", event.quit.reason_str)
        elif(event.type == CHIAKI_EVENT_LOGIN_PIN_REQUEST):
            printf("Login PIN request received - handling this is not implemented\n")
        elif(event.type == CHIAKI_EVENT_RUMBLE):
            printf("Rumble signal received\n")
        elif(event.type == CHIAKI_EVENT_TRIGGER_EFFECTS):
            printf("Trigger effects received\n")
        else:
            printf("Unkown event received")


    @staticmethod
    cdef void dummy_frame_cb(uint8_t* buf, size_t buf_size, void* user) noexcept:
        printf("dummy_frame_cb\n")

    @staticmethod
    cdef void dummy_header_cb(ChiakiAudioHeader* header, void* user) noexcept:
        printf("dummy_header_cb\n")

