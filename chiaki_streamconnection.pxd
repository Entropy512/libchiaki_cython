from libc.stdint cimport uint8_t

cdef extern from "chiaki/streamconnection.h":

    ctypedef chiaki_session_t ChiakiSession

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
        bool feedback_sender_active
        ChiakiMutex feedback_sender_mutex
        ChiakiCond state_cond
        ChiakiMutex state_mutex
        int state
        bool state_finished
        bool state_failed
        bool should_stop
        bool remote_disconnected
        char* remote_disconnect_reason

    ctypedef chiaki_stream_connection_t ChiakiStreamConnection

    ChiakiErrorCode chiaki_stream_connection_init(ChiakiStreamConnection* stream_connection, ChiakiSession* session)

    void chiaki_stream_connection_fini(ChiakiStreamConnection* stream_connection)

    ChiakiErrorCode chiaki_stream_connection_run(ChiakiStreamConnection* stream_connection)

    ChiakiErrorCode chiaki_stream_connection_stop(ChiakiStreamConnection* stream_connection)

    ChiakiErrorCode stream_connection_send_corrupt_frame(ChiakiStreamConnection* stream_connection, ChiakiSeqNum16 start, ChiakiSeqNum16 end)
