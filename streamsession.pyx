from libchiaki cimport *
from libc.string cimport memset, memcpy
from libc.stdio cimport printf
import socket
import struct
from time import sleep

cdef class ChiakiStreamSession:
    cdef ChiakiLog log
    cdef ChiakiSession session
    cdef ChiakiErrorCode err
    cdef ChiakiTarget target
    cdef bint is_ps5
    cdef public ChiakiControllerState controller_state
    cdef public ChiakiControllerState test_state
    cdef uint64_t int_regkey
    cdef char* host

    def __cinit__(self, host=None, regkey = None, rpkey = None):
        self.int_regkey = <uint64_t> int(regkey,16)
        temphost = host.encode('UTF-8')
        self.host = <char *> temphost

        self.target = CHIAKI_TARGET_PS5_1
        self.is_ps5 = True #FIXME:  Support PS4s at some point.  But these controller-only remoteplay hax are primarily for PS5

        chiaki_log_init(&self.log, CHIAKI_LOG_INFO | CHIAKI_LOG_ERROR | CHIAKI_LOG_DEBUG, chiaki_log_cb_print, NULL)

        chiaki_controller_state_set_idle(&self.controller_state)
    
        chiaki_controller_state_set_idle(&self.test_state)

        ''' Here in case we need it, hopefully if we don't set a sink it'll just do what we want
        cdef ChiakiAudioSink dummy_sink
        chiaki_session_set_audio_sink(&self.session, &dummy_sink)
        '''

        chiaki_session_set_event_cb(&self.session, <ChiakiEventCallback> self.event_cb, <void*> self)

    @staticmethod
    cdef void event_cb(ChiakiEvent *event, void *selfref) noexcept:
        self = <object> selfref
        print(self.host)