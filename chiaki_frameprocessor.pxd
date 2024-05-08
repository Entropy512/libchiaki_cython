from libc.stdint cimport uint64_t, uint8_t

cdef extern from "chiaki/frameprocessor.h":

    cdef struct chiaki_stream_stats_t:
        uint64_t frames
        uint64_t bytes

    ctypedef chiaki_stream_stats_t ChiakiStreamStats

    void chiaki_stream_stats_reset(ChiakiStreamStats* stats)

    void chiaki_stream_stats_frame(ChiakiStreamStats* stats, uint64_t size)

    uint64_t chiaki_stream_stats_bitrate(ChiakiStreamStats* stats, uint64_t framerate)

    cdef struct chiaki_frame_unit_t

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
        bool flushed
        ChiakiStreamStats stream_stats

    ctypedef chiaki_frame_processor_t ChiakiFrameProcessor

    cpdef enum chiaki_frame_flush_result_t:
        CHIAKI_FRAME_PROCESSOR_FLUSH_RESULT_SUCCESS
        CHIAKI_FRAME_PROCESSOR_FLUSH_RESULT_FEC_SUCCESS
        CHIAKI_FRAME_PROCESSOR_FLUSH_RESULT_FEC_FAILED
        CHIAKI_FRAME_PROCESSOR_FLUSH_RESULT_FAILED

    ctypedef chiaki_frame_flush_result_t ChiakiFrameProcessorFlushResult

    void chiaki_frame_processor_init(ChiakiFrameProcessor* frame_processor, ChiakiLog* log)

    void chiaki_frame_processor_fini(ChiakiFrameProcessor* frame_processor)

    void chiaki_frame_processor_report_packet_stats(ChiakiFrameProcessor* frame_processor, ChiakiPacketStats* packet_stats)

    ChiakiErrorCode chiaki_frame_processor_alloc_frame(ChiakiFrameProcessor* frame_processor, ChiakiTakionAVPacket* packet)

    ChiakiErrorCode chiaki_frame_processor_put_unit(ChiakiFrameProcessor* frame_processor, ChiakiTakionAVPacket* packet)

    ChiakiFrameProcessorFlushResult chiaki_frame_processor_flush(ChiakiFrameProcessor* frame_processor, uint8_t** frame, size_t* frame_size)

    bool chiaki_frame_processor_flush_possible(ChiakiFrameProcessor* frame_processor)
