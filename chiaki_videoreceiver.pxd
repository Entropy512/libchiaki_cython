from libc.stdint cimport int32_t

cdef extern from "chiaki/videoreceiver.h":

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

    void chiaki_video_receiver_init(ChiakiVideoReceiver* video_receiver, chiaki_session_t* session, ChiakiPacketStats* packet_stats)

    void chiaki_video_receiver_fini(ChiakiVideoReceiver* video_receiver)

    void chiaki_video_receiver_stream_info(ChiakiVideoReceiver* video_receiver, ChiakiVideoProfile* profiles, size_t profiles_count)

    void chiaki_video_receiver_av_packet(ChiakiVideoReceiver* video_receiver, ChiakiTakionAVPacket* packet)

    ChiakiVideoReceiver* chiaki_video_receiver_new(chiaki_session_t* session, ChiakiPacketStats* packet_stats)

    void chiaki_video_receiver_free(ChiakiVideoReceiver* video_receiver)
