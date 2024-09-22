#!/usr/bin/env python3

from PyQt6.QtCore import QSettings
from chiaki_streamsession import ChiakiStreamSession, JoyButtons, JoyAxes
import argparse

from evdev import ecodes, list_devices, AbsInfo, InputDevice
import sys, select, tty, termios
import numpy as np
from numpy_ringbuffer import RingBuffer

import pyformulas as pf
import matplotlib.pyplot as plt
from matplotlib.ticker import (AutoMinorLocator, MultipleLocator)
from time import time, sleep
import scipy

import pygame

from eventtimer import EventTimer

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

def expo_stick_remap(inscale, outscale,str, dz, value):
    normval = np.sign(value)*max((abs(value)-dz),0)/(inscale-dz)
    mapval = (1-str)*normval + str*np.power(normval,3.0)
    return int(np.clip(mapval, -1.0, 1.0)*outscale)

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
def handle_evdev_event(ss,e):
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
                ss.HandleAxisEvent(JoyAxes.LX, expo_stick_remap(32767, 32767, 0.5, 1024, e.value))
            case ecodes.ABS_Y:
                ss.HandleAxisEvent(JoyAxes.LY, expo_stick_remap(32767, 32767, 0.5, 1024, e.value))
            case ecodes.ABS_Z:
                ss.HandleAxisEvent(JoyAxes.LZ, e.value >> 2)
            case ecodes.ABS_RX:
                ss.HandleAxisEvent(JoyAxes.RX, expo_stick_remap(32767, 32767, 0.5, 0, e.value))
            case ecodes.ABS_RY:
                ss.HandleAxisEvent(JoyAxes.RY, expo_stick_remap(32767, 32767, 0.5, 0, e.value))
            case ecodes.ABS_RZ:
                ss.HandleAxisEvent(JoyAxes.RZ, e.value >> 2)
            case ecodes.ABS_HAT0X:
                ss.HandleButtonEvent(JoyButtons.DPAD_LEFT, (e.value == -1))
                ss.HandleButtonEvent(JoyButtons.DPAD_RIGHT, (e.value == 1))
            case ecodes.ABS_HAT0Y:
                ss.HandleButtonEvent(JoyButtons.DPAD_UP, (e.value == -1))
                ss.HandleButtonEvent(JoyButtons.DPAD_DOWN, (e.value == 1))

'''
Xbox Elite mappings, pygame edition:
Axes:
0 : LX
1 : LY
2 : LZ (trigger)
3 : RX
4 : RY
5 : RZ (trigger)

Buttons:
0: A
1: B
2: X
3: Y
4: LT
5: RT
6: Windows???
7: Hamburger?
8: Xbox button
9: Left Thumbstick click
10: Right Thumbstick click
11: Upper right paddle
12: Lower right paddle
13: Upper Left paddle
14: Lower left paddle
Why does xpad give the right paddles lower values than left???
'''
def handle_pygame_event(ss,e):
    global joysticks
    if not hasattr(handle_pygame_event, "ievtimer"):
        handle_pygame_event.ievtimer = EventTimer()  # it doesn't exist yet, so initialize it
        handle_pygame_event.ievtimer.start(0.004, periodic=True)

    if e.type == pygame.JOYDEVICEADDED:
        # This event will be generated when the program starts for every
        # joystick, filling up the list without needing to create them manually.
        joy = pygame.joystick.Joystick(e.device_index)
        joysticks[joy.get_instance_id()] = joy
        print(f"Joystick {joy.get_instance_id()} connencted")

    if e.type == pygame.JOYDEVICEREMOVED:
        del joysticks[e.instance_id]
        print(f"Joystick {e.instance_id} disconnected")

    if (e.type == pygame.JOYBUTTONDOWN) or (e.type == pygame.JOYBUTTONUP):
        value = (e.type == pygame.JOYBUTTONDOWN)
        match e.button:
            case 8: #Xbox button
                ss.HandleButtonEvent(JoyButtons.TOUCHPAD, value)
            case 6: #Share?  Select? Guide?
                ss.HandleButtonEvent(JoyButtons.PS, value)
            case 7: #Hamburger?
                ss.HandleButtonEvent(JoyButtons.OPTIONS, value)
            case k if k in [9, 14]: #Left thumb or lower left paddle
                ss.HandleButtonEvent(JoyButtons.L3, value)
            case k if k in [10, 12]: #Right thumb or lower right paddle
                ss.HandleButtonEvent(JoyButtons.R3, value)
            case k if k in [4, 13]: #LT or upper left paddle
                ss.HandleButtonEvent(JoyButtons.L1, value)
            case k if k in [5, 11]: #RT or upper right paddle
                ss.HandleButtonEvent(JoyButtons.R1, value)
            case 0: #A
                ss.HandleButtonEvent(JoyButtons.CROSS, value)
            case 1: #B
                ss.HandleButtonEvent(JoyButtons.MOON, value)
            case 2: #X
                ss.HandleButtonEvent(JoyButtons.BOX, value)
            case 3: #Y
                ss.HandleButtonEvent(JoyButtons.PYRAMID, value)


    if e.type == pygame.JOYAXISMOTION:
        match e.axis:
            case 0:
                ss.HandleAxisEvent(JoyAxes.LX, int(expo_stick_remap(1.0, 32767, 0.5, 0.025, e.value)))
            case 1:
                ss.HandleAxisEvent(JoyAxes.LY, int(expo_stick_remap(1.0, 32767, 0.5, 0.025, e.value)))
            case 2:
                ss.HandleAxisEvent(JoyAxes.LZ, int(max(0,(e.value+1)*255/2)))
            case 3:
                ss.HandleAxisEvent(JoyAxes.RX, int(expo_stick_remap(1.0, 32767, 0.5, 0.0, e.value)))
            case 4:
                ss.HandleAxisEvent(JoyAxes.RY, int(expo_stick_remap(1.0, 32767, 0.5, 0.0, e.value)))
            case 5:
                ss.HandleAxisEvent(JoyAxes.RZ, int(max(0,(e.value+1)*255/2)))

    if e.type == pygame.JOYHATMOTION:
        if(e.hat == 0):
                ss.HandleButtonEvent(JoyButtons.DPAD_LEFT, (e.value[0] == -1))
                ss.HandleButtonEvent(JoyButtons.DPAD_RIGHT, (e.value[0] == 1))
                ss.HandleButtonEvent(JoyButtons.DPAD_UP, (e.value[1] == 1))
                ss.HandleButtonEvent(JoyButtons.DPAD_DOWN, (e.value[1] == -1))

    if(handle_pygame_event.ievtimer.check()):
        ss.SendFeedbackState()

def haptics_callback(data):
    # requires https://github.com/eric-wieser/numpy_ringbuffer/pull/18
    rbuf.extend(data/32767) #normalize to the equivalent of 1V p-p
    global last_haptic_time
    last_haptic_time = time()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--host', required=True,
        help='PS5 to connect to')

    args = vars(ap.parse_args())

    chiaki_settings = QSettings('Chiaki', 'Chiaki')

    regkey = chiaki_settings.value('registered_hosts/1/rp_regist_key')

    morning = chiaki_settings.value('registered_hosts/1/rp_key')

    ss = ChiakiStreamSession(host=args['host'], regkey=regkey.data(), rpkey=morning.data())

    ss.set_haptics_callback(haptics_callback)

    if(0):
        xonedev = InputDevice('/dev/input/event20')
        indevices = [xonedev]

        fd_to_device = {dev.fd: dev for dev in indevices}

    ss.Start()


    while True:
        if(0): #disable evdev for now, keep the code for potential future use after refactoring
            r, w, e = select.select(fd_to_device, [], [], 0)

            for fd in r:
                for event in fd_to_device[fd].read():
                    #print_event(event)
                    handle_event(ss, event)

        '''
        Using evdev for this results in the quit function being executed any time we press q - even elsewhere.
        So read sys.stdin instead.  In the process, we've dropped support for all other keyboard inputs since controller input is fully functional now
        '''
        r, w, e = select.select([sys.stdin], [], [], 0)

        global plot_pause
        for fd in r:
            if fd == sys.stdin:
                inchar = sys.stdin.read(1)
                if(inchar == 'q'):
                    ss.Stop()
                    return
                if(inchar == 'p'):
                    plot_pause = True
                if(inchar == 'r'):
                    plot_pause = False

        '''
        Handle pygame joystick events
        '''

        for pgevent in pygame.event.get():
            handle_pygame_event(ss, pgevent)

        global last_haptic_time
        if((time() - last_haptic_time) >= 0.04):
           last_haptic_time = time() - 0.02
           rbuf.extend(np.zeros(60))

        global last_power_time
        if((time() - last_power_time) >= buffer_time):
            last_power_time = time()
            lpow, hpow = get_sigpower(np.array(rbuf))
            for joy in joysticks.keys():
                joysticks[joy].rumble(lpow, hpow, int(buffer_time*1000))

        global last_plot_time
        if(0):
            if(((time() - last_plot_time) >= plot_time) and not plot_pause):
                last_plot_time = time()
                ln.set_data(fdata, np.abs(fft.rfft(np.array(rbuf))))
                fig.canvas.draw()
                image = np.frombuffer(fig.canvas.buffer_rgba(), dtype=np.uint8)
                image = image.reshape(fig.canvas.get_width_height()[::-1] + (4,))
                image = np.flip(image[:,:,0:3], axis=2) #screen wants BGR, and we want to drop alpha
                screen.update(image)

        sleep(0)
# https://stackoverflow.com/questions/42169348/calculating-bandpower-of-a-signal-in-python
def get_sigpower(data):
    f, Pxx = scipy.signal.periodogram(np.array(data), fs=fs, scaling='density')
    nyq = fs/2
    ind_lowcut = np.argmax(f > 85) - 1
    ind_highcut = np.argmax(f >= 350) - 1 #Do we just want to take all high frequency content???
    lowpow = np.sqrt(scipy.integrate.trapezoid(Pxx[:ind_lowcut], f[:ind_lowcut]))
    highpow = np.sqrt(scipy.integrate.trapezoid(Pxx[ind_lowcut:ind_highcut], f[ind_lowcut:ind_highcut]))
    return lowpow, highpow

try:
    buffer_time = 0.06 #3 haptics packets
    fs = 3000
    nyq = fs/2
    plot_pause = False
    buf_cap = int(buffer_time*fs)
    rbuf = RingBuffer(capacity=buf_cap, dtype=np.float32)
    rbuf.extend(np.zeros(buf_cap))

    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    tty.setcbreak(sys.stdin)

    if(0):
        fig,ax = plt.subplots()
        fig.set_figwidth(15)
        fig.set_figheight(6)
        fig.set_dpi(100)
        # https://stackoverflow.com/a/49594258/4434513
        canvas = np.zeros((480,1080,3))
        screen = pf.screen(canvas, 'Audio Data')
        xdata = np.arange(buf_cap)/3000
        fdata = np.linspace(0, 3000, 513)
        maxfreq = 150
        ax.set_xlim(0,maxfreq)
        ax.set_ylim(0, 32767)
        ax.xaxis.set_major_locator(MultipleLocator(maxfreq/10))
        ax.yaxis.set_major_locator(MultipleLocator(10000))
        ax.xaxis.set_minor_locator(AutoMinorLocator(5))
        ax.yaxis.set_minor_locator(AutoMinorLocator(5))
        ax.grid(which='major', color='#CCCCCC', linestyle='--')
        ax.grid(which='minor', color='#CCCCCC', linestyle=':')
        ln = ax.plot(fdata, np.abs(fft.rfft(np.array(rbuf))), color='blue')[0]
        last_plot_time = time()

    last_power_time = time()
    last_haptic_time = time()

    pygame.init()
    joysticks = {}
    main()
finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    pygame.quit()