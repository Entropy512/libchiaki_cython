#!/usr/bin/env python3

from PyQt6.QtCore import QSettings
from chiaki_streamsession import ChiakiStreamSession, JoyButtons, JoyAxes
import argparse

from evdev import ecodes, list_devices, AbsInfo, InputDevice
import sys, select, tty, termios

def print_event(e):
    if e.type == ecodes.EV_SYN:
        if e.code == ecodes.SYN_MT_REPORT:
            msg = "time {:<16} +++++++++ {} ++++++++"
        else:
            msg = "time {:<16} --------- {} --------"
        print(msg.format(e.timestamp(), ecodes.SYN[e.code]))
    else:
        if e.type in ecodes.bytype:
            codename = ecodes.bytype[e.type][e.code]
        else:
            codename = "?"

        evfmt = "time {:<16} type {} ({}), code {:<4} ({}), value {}"
        print(evfmt.format(e.timestamp(), e.type, ecodes.EV[e.type], e.code, codename, e.value))

"""
Xbox Elite event mappings:
type = EV_ABS for analog, EV_KEY for buttons
Right stick:  ABS_RX and ABS_RY, looks like -32767 to 32767
Left stick: ABS_X and ABS_Y
Left trigger: ABS_Z
Right trigger: ABS_RZ
Dpad:  ABS_HAT0X/0Y, values are -1,0,+1
Xbox button:  BTN_MODE
Share? : BTN_SELECT
Hamburger? : BTN_START
A: BTN_A
B: BTN_B
X: BTN_X
Y: BTN_Y
Bumper R: BTN_TR
Bumper L: BTN_TL
Left Thumb: BTN_THUMBL
Right Thumb: BTN_THUMBR
"""
def handle_event(ss,e):
    if e.type == ecodes.EV_KEY:
        match e.code:
            case ecodes.KEY_Q:  # obsolete, leaving it here just in case
                ss.Stop()
                exit()
            case k if k in [ecodes.KEY_A, ecodes.KEY_LEFT]:
                ss.HandleButtonEvent(JoyButtons.DPAD_LEFT, e.value)
            case k if k in [ecodes.KEY_D, ecodes.KEY_RIGHT]:
                ss.HandleButtonEvent(JoyButtons.DPAD_RIGHT, e.value)
            case k if k in [ecodes.KEY_W, ecodes.KEY_UP]:
                ss.HandleButtonEvent(JoyButtons.DPAD_UP, e.value)
            case k if k in [ecodes.KEY_S, ecodes.KEY_DOWN]:
                ss.HandleButtonEvent(JoyButtons.DPAD_DOWN, e.value)
            case k if k in [ecodes.BTN_MODE]:
                ss.HandleButtonEvent(JoyButtons.TOUCHPAD, e.value)
            case k if k in [ecodes.BTN_SELECT]:
                ss.HandleButtonEvent(JoyButtons.PS, e.value)
            case k if k in [ecodes.BTN_START]:
                ss.HandleButtonEvent(JoyButtons.OPTIONS, e.value)
            case k if k in [ecodes.BTN_THUMBL]:
                ss.HandleButtonEvent(JoyButtons.L3, e.value)
            case k if k in [ecodes.BTN_THUMBR]:
                ss.HandleButtonEvent(JoyButtons.R3, e.value)
            case k if k in [ecodes.BTN_TL]:
                ss.HandleButtonEvent(JoyButtons.L1, e.value)
            case k if k in [ecodes.BTN_TR]:
                ss.HandleButtonEvent(JoyButtons.R1, e.value)
            case k if k in [ecodes.BTN_A]:
                ss.HandleButtonEvent(JoyButtons.CROSS, e.value)
            case k if k in [ecodes.BTN_B]:
                ss.HandleButtonEvent(JoyButtons.MOON, e.value)
            case k if k in [ecodes.BTN_X]:
                ss.HandleButtonEvent(JoyButtons.BOX, e.value)
            case k if k in [ecodes.BTN_Y]:
                ss.HandleButtonEvent(JoyButtons.PYRAMID, e.value)

    if e.type == ecodes.EV_ABS:
        match e.code:
            case ecodes.ABS_X:
                ss.HandleAxisEvent(JoyAxes.LX, e.value)
            case ecodes.ABS_Y:
                ss.HandleAxisEvent(JoyAxes.LY, e.value)
            case ecodes.ABS_Z:
                ss.HandleAxisEvent(JoyAxes.LZ, e.value >> 2)
            case ecodes.ABS_RX:
                ss.HandleAxisEvent(JoyAxes.RX, e.value)
            case ecodes.ABS_RY:
                ss.HandleAxisEvent(JoyAxes.RY, e.value)
            case ecodes.ABS_RZ:
                ss.HandleAxisEvent(JoyAxes.RZ, e.value >> 2)
            case ecodes.ABS_HAT0X:
                ss.HandleButtonEvent(JoyButtons.DPAD_LEFT, (e.value == -1), sendImm=False)
                ss.HandleButtonEvent(JoyButtons.DPAD_RIGHT, (e.value == 1))
            case ecodes.ABS_HAT0Y:
                ss.HandleButtonEvent(JoyButtons.DPAD_UP, (e.value == -1), sendImm=False)
                ss.HandleButtonEvent(JoyButtons.DPAD_DOWN, (e.value == 1))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--host', required=True,
        help='PS5 to connect to')

    args = vars(ap.parse_args())

    chiaki_settings = QSettings('Chiaki', 'Chiaki')

    regkey = chiaki_settings.value('registered_hosts/1/rp_regist_key')

    morning = chiaki_settings.value('registered_hosts/1/rp_key')

    ss = ChiakiStreamSession(host=args['host'], regkey=regkey.data(), rpkey=morning.data())

    xonedev = InputDevice('/dev/input/event20')
    indevices = [xonedev]

    fd_to_device = {dev.fd: dev for dev in indevices}

    ss.Start()

    while True:
        r, w, e = select.select(fd_to_device, [], [], 0)

        for fd in r:
            for event in fd_to_device[fd].read():
                #print_event(event)
                handle_event(ss,event)

        r, w, e = select.select([sys.stdin], [], [], 0)

        '''
        Using evdev for this results in the quit function being executed any time we press q - even elsewhere.
        So read sys.stdin instead.  In the process, we've dropped support for all other keyboard inputs since controller input is fully functional now
        '''
        for fd in r:
            if fd == sys.stdin:
                inchar = sys.stdin.read(1)
                if(inchar == 'q'):
                    ss.Stop()
                    return

try:
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    tty.setcbreak(sys.stdin)
    main()
finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)