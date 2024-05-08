from libc.stdint cimport uint16_t, int8_t, uint32_t, uint8_t, int16_t

cdef extern from "chiaki/controller.h":

    cpdef enum chiaki_controller_button_t:
        CHIAKI_CONTROLLER_BUTTON_CROSS
        CHIAKI_CONTROLLER_BUTTON_MOON
        CHIAKI_CONTROLLER_BUTTON_BOX
        CHIAKI_CONTROLLER_BUTTON_PYRAMID
        CHIAKI_CONTROLLER_BUTTON_DPAD_LEFT
        CHIAKI_CONTROLLER_BUTTON_DPAD_RIGHT
        CHIAKI_CONTROLLER_BUTTON_DPAD_UP
        CHIAKI_CONTROLLER_BUTTON_DPAD_DOWN
        CHIAKI_CONTROLLER_BUTTON_L1
        CHIAKI_CONTROLLER_BUTTON_R1
        CHIAKI_CONTROLLER_BUTTON_L3
        CHIAKI_CONTROLLER_BUTTON_R3
        CHIAKI_CONTROLLER_BUTTON_OPTIONS
        CHIAKI_CONTROLLER_BUTTON_SHARE
        CHIAKI_CONTROLLER_BUTTON_TOUCHPAD
        CHIAKI_CONTROLLER_BUTTON_PS

    ctypedef chiaki_controller_button_t ChiakiControllerButton

    cpdef enum chiaki_controller_analog_button_t:
        CHIAKI_CONTROLLER_ANALOG_BUTTON_L2
        CHIAKI_CONTROLLER_ANALOG_BUTTON_R2

    ctypedef chiaki_controller_analog_button_t ChiakiControllerAnalogButton

    cdef struct chiaki_controller_touch_t:
        uint16_t x
        uint16_t y
        int8_t id

    ctypedef chiaki_controller_touch_t ChiakiControllerTouch

    cdef struct chiaki_controller_state_t:
        uint32_t buttons
        uint8_t l2_state
        uint8_t r2_state
        int16_t left_x
        int16_t left_y
        int16_t right_x
        int16_t right_y
        uint8_t touch_id_next
        ChiakiControllerTouch touches[2]
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

    ctypedef chiaki_controller_state_t ChiakiControllerState

    void chiaki_controller_state_set_idle(ChiakiControllerState* state)

    int8_t chiaki_controller_state_start_touch(ChiakiControllerState* state, uint16_t x, uint16_t y)

    void chiaki_controller_state_stop_touch(ChiakiControllerState* state, uint8_t id)

    void chiaki_controller_state_set_touch_pos(ChiakiControllerState* state, uint8_t id, uint16_t x, uint16_t y)

    bool chiaki_controller_state_equals(ChiakiControllerState* a, ChiakiControllerState* b)

    void chiaki_controller_state_or(ChiakiControllerState* out, ChiakiControllerState* a, ChiakiControllerState* b)
