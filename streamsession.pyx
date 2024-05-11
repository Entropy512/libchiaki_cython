from libchiaki cimport *
from libc.string cimport memset, memcpy
from libc.stdio cimport printf
import socket
import struct
from time import sleep

cdef class ChiakiStreamSession:
    cdef ChiakiLog log
    cdef ChiakiSession session
    cdef ChiakiTarget target
    cdef bint is_ps5
    cdef public ChiakiControllerState controller_state
    cdef public ChiakiControllerState test_state
    cdef char* regkey
    cdef char* rpkey
    cdef readonly char* host
    cdef public bint connected

    def __cinit__(self, host=None, regkey = None, rpkey = None):
        self.regkey = <char*> regkey
        self.rpkey = <char*> rpkey
        temphost = host.encode('UTF-8')
        self.host = <char *> temphost

        self.connected = False
        self.target = CHIAKI_TARGET_PS5_1
        self.is_ps5 = True #FIXME:  Support PS4s at some point.  But these controller-only remoteplay hax are primarily for PS5

        chiaki_log_init(&self.log, CHIAKI_LOG_INFO | CHIAKI_LOG_ERROR | CHIAKI_LOG_DEBUG, chiaki_log_cb_print, NULL)

        chiaki_controller_state_set_idle(&self.controller_state)
    
        chiaki_controller_state_set_idle(&self.test_state)

        cdef ChiakiAudioSink dummy_sink
        dummy_sink.user = &self.log
        dummy_sink.frame_cb = self.dummy_frame_cb
        dummy_sink.header_cb = self.dummy_header_cb
        chiaki_session_set_audio_sink(&self.session, &dummy_sink)

        cdef ChiakiConnectVideoProfile vid_profile
        chiaki_connect_video_profile_preset(&vid_profile, CHIAKI_VIDEO_RESOLUTION_PRESET_360p, CHIAKI_VIDEO_FPS_PRESET_30)

        cdef ChiakiConnectInfo connect_info
        connect_info.ps5 = chiaki_target_is_ps5(self.target)
        connect_info.host = self.host
        connect_info.enable_keyboard = False #Pretty sure this means disabling sending of keyboard events to the PS5, not "do not handle local keyboard"
        connect_info.enable_dualsense = False #No intention right now of using a dualsense with haptics
        connect_info.video_profile = vid_profile
        connect_info.video_profile_auto_downgrade = True
        connect_info.morning = self.rpkey
        connect_info.regist_key = self.regkey

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

