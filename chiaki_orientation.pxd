from libc.stdint cimport uint32_t, uint64_t

cdef extern from "chiaki/orientation.h":

    cdef struct chiaki_orientation_t:
        float x
        float y
        float z
        float w

    ctypedef chiaki_orientation_t ChiakiOrientation

    void chiaki_orientation_init(ChiakiOrientation* orient)

    void chiaki_orientation_update(ChiakiOrientation* orient, float gx, float gy, float gz, float ax, float ay, float az, float beta, float time_step_sec)

    cdef struct chiaki_orientation_tracker_t:
        float gyro_x
        float gyro_y
        float gyro_z
        float accel_x
        float accel_y
        float accel_z
        ChiakiOrientation orient
        uint32_t timestamp
        uint64_t sample_index

    ctypedef chiaki_orientation_tracker_t ChiakiOrientationTracker

    void chiaki_orientation_tracker_init(ChiakiOrientationTracker* tracker)

    void chiaki_orientation_tracker_update(ChiakiOrientationTracker* tracker, float gx, float gy, float gz, float ax, float ay, float az, uint32_t timestamp_us)

    void chiaki_orientation_tracker_apply_to_controller_state(ChiakiOrientationTracker* tracker, ChiakiControllerState* state)
