from libc.stdint cimport uint8_t

cdef extern from "chiaki/audioreceiver.h":

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
        bool frame_index_startup
        ChiakiPacketStats* packet_stats

    ctypedef chiaki_audio_receiver_t ChiakiAudioReceiver

    ChiakiErrorCode chiaki_audio_receiver_init(ChiakiAudioReceiver* audio_receiver, chiaki_session_t* session, ChiakiPacketStats* packet_stats)

    void chiaki_audio_receiver_fini(ChiakiAudioReceiver* audio_receiver)

    void chiaki_audio_receiver_stream_info(ChiakiAudioReceiver* audio_receiver, ChiakiAudioHeader* audio_header)

    void chiaki_audio_receiver_av_packet(ChiakiAudioReceiver* audio_receiver, ChiakiTakionAVPacket* packet)

    ChiakiAudioReceiver* chiaki_audio_receiver_new(chiaki_session_t* session, ChiakiPacketStats* packet_stats)

    void chiaki_audio_receiver_free(ChiakiAudioReceiver* audio_receiver)
