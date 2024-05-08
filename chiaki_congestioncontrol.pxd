cdef extern from "chiaki/congestioncontrol.h":

    cdef struct chiaki_congestion_control_t:
        ChiakiTakion* takion
        ChiakiPacketStats* stats
        ChiakiThread thread
        ChiakiBoolPredCond stop_cond

    ctypedef chiaki_congestion_control_t ChiakiCongestionControl

    ChiakiErrorCode chiaki_congestion_control_start(ChiakiCongestionControl* control, ChiakiTakion* takion, ChiakiPacketStats* stats)

    ChiakiErrorCode chiaki_congestion_control_stop(ChiakiCongestionControl* control)
