from libc.stdint cimport uint8_t, uint64_t, uint32_t, uint16_t

cdef extern from "chiaki/ctrl.h":

    ctypedef chiaki_ctrl_message_queue_t ChiakiCtrlMessageQueue

    cdef struct chiaki_ctrl_t:
        chiaki_session_t* session
        ChiakiThread thread
        bool should_stop
        bool login_pin_entered
        uint8_t* login_pin
        size_t login_pin_size
        ChiakiCtrlMessageQueue* msg_queue
        ChiakiStopPipe notif_pipe
        ChiakiMutex notif_mutex
        bool login_pin_requested
        chiaki_socket_t sock
        uint8_t recv_buf[512]
        size_t recv_buf_size
        uint64_t crypt_counter_local
        uint64_t crypt_counter_remote
        uint32_t keyboard_text_counter

    ctypedef chiaki_ctrl_t ChiakiCtrl

    ChiakiErrorCode chiaki_ctrl_init(ChiakiCtrl* ctrl, chiaki_session_t* session)

    ChiakiErrorCode chiaki_ctrl_start(ChiakiCtrl* ctrl)

    void chiaki_ctrl_stop(ChiakiCtrl* ctrl)

    ChiakiErrorCode chiaki_ctrl_join(ChiakiCtrl* ctrl)

    void chiaki_ctrl_fini(ChiakiCtrl* ctrl)

    ChiakiErrorCode chiaki_ctrl_send_message(ChiakiCtrl* ctrl, uint16_t type, const uint8_t* payload, size_t payload_size)

    void chiaki_ctrl_set_login_pin(ChiakiCtrl* ctrl, const uint8_t* pin, size_t pin_size)

    ChiakiErrorCode chiaki_ctrl_goto_bed(ChiakiCtrl* ctrl)

    ChiakiErrorCode chiaki_ctrl_keyboard_set_text(ChiakiCtrl* ctrl, const char* text)

    ChiakiErrorCode chiaki_ctrl_keyboard_accept(ChiakiCtrl* ctrl)

    ChiakiErrorCode chiaki_ctrl_keyboard_reject(ChiakiCtrl* ctrl)
