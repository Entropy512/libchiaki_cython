from libc.stdint cimport int16_t, uint8_t, uint64_t, uint16_t

cdef extern from "chiaki/feedback.h":

    cdef struct chiaki_feedback_state_t:
        float gyro_x
        float gyro_y
        float gyro_z
        float accel_x
        float accel_y
        float accel_z
        float orient_x
        float orient_y
        float orient_z
        float orient_w
        int16_t left_x
        int16_t left_y
        int16_t right_x
        int16_t right_y

    ctypedef chiaki_feedback_state_t ChiakiFeedbackState

    void chiaki_feedback_state_format_v9(uint8_t* buf, ChiakiFeedbackState* state)

    void chiaki_feedback_state_format_v12(uint8_t* buf, ChiakiFeedbackState* state)

    cdef struct chiaki_feedback_history_event_t:
        uint8_t buf[0x5]
        size_t len

    ctypedef chiaki_feedback_history_event_t ChiakiFeedbackHistoryEvent

    ChiakiErrorCode chiaki_feedback_history_event_set_button(ChiakiFeedbackHistoryEvent* event, uint64_t button, uint8_t state)

    void chiaki_feedback_history_event_set_touchpad(ChiakiFeedbackHistoryEvent* event, bool down, uint8_t pointer_id, uint16_t x, uint16_t y)

    cdef struct chiaki_feedback_history_buffer_t:
        ChiakiFeedbackHistoryEvent* events
        size_t size
        size_t begin
        size_t len

    ctypedef chiaki_feedback_history_buffer_t ChiakiFeedbackHistoryBuffer

    ChiakiErrorCode chiaki_feedback_history_buffer_init(ChiakiFeedbackHistoryBuffer* feedback_history_buffer, size_t size)

    void chiaki_feedback_history_buffer_fini(ChiakiFeedbackHistoryBuffer* feedback_history_buffer)

    ChiakiErrorCode chiaki_feedback_history_buffer_format(ChiakiFeedbackHistoryBuffer* feedback_history_buffer, uint8_t* buf, size_t* buf_size)

    void chiaki_feedback_history_buffer_push(ChiakiFeedbackHistoryBuffer* feedback_history_buffer, ChiakiFeedbackHistoryEvent* event)
