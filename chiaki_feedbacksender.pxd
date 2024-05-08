cdef extern from "chiaki/feedbacksender.h":

    cdef struct chiaki_feedback_sender_t:
        ChiakiLog* log
        ChiakiTakion* takion
        ChiakiThread thread
        ChiakiSeqNum16 state_seq_num
        ChiakiSeqNum16 history_seq_num
        ChiakiFeedbackHistoryBuffer history_buf
        bool should_stop
        ChiakiControllerState controller_state_prev
        ChiakiControllerState controller_state
        bool controller_state_changed
        ChiakiMutex state_mutex
        ChiakiCond state_cond

    ctypedef chiaki_feedback_sender_t ChiakiFeedbackSender

    ChiakiErrorCode chiaki_feedback_sender_init(ChiakiFeedbackSender* feedback_sender, ChiakiTakion* takion)

    void chiaki_feedback_sender_fini(ChiakiFeedbackSender* feedback_sender)

    ChiakiErrorCode chiaki_feedback_sender_set_controller_state(ChiakiFeedbackSender* feedback_sender, ChiakiControllerState* state)
