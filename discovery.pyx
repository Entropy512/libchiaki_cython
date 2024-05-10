from libchiaki cimport *
from libc.string cimport memset, memcpy
from libc.stdio cimport printf
from cython.operator import dereference
import socket
import struct
from time import sleep

'''
Trying to use a Cython global variable in a callback doesn't seem to play nice even if you use the "global" keyword
Fortunately, we can pass a pointer to an arbitrary user structure to ChiakiDiscoveryCb functions, and modify that
'''
cdef struct DiscoveryCbData:
    ChiakiLog *log
    bint discovery_is_running

#Basically copied from chiaki-cli's discovery callback
cdef void discovery_cb(ChiakiDiscoveryHost *host, void *user) noexcept:
    cdef DiscoveryCbData *cbuser = <DiscoveryCbData *> user
    cdef ChiakiLog *log = <ChiakiLog *>cbuser.log

    #WARNING:  Don't mix Python's print() with anything that uses C printing functions.  C functions appear to flush immediately, but not Python's print(), which can lead to issues diagnosinc exactly where something segfaults
    chiaki_log(log, CHIAKI_LOG_INFO, "--")
    chiaki_log(log, CHIAKI_LOG_INFO, "Discovered Host:")
    chiaki_log(log, CHIAKI_LOG_INFO, "State:                             %s", chiaki_discovery_host_state_string(host.state))

    if(host.system_version):
        chiaki_log(log, CHIAKI_LOG_INFO, "System Version:                    %s", host.system_version)

    if(host.device_discovery_protocol_version):
        chiaki_log(log, CHIAKI_LOG_INFO, "Device Discovery Protocol Version: %s", host.device_discovery_protocol_version)


    if(host.host_request_port):
        chiaki_log(log, CHIAKI_LOG_INFO, "Request Port:                      %hu", <uint16_t> host.host_request_port)

    if(host.host_name):
        chiaki_log(log, CHIAKI_LOG_INFO, "Host Name:                         %s", host.host_name)

    if(host.host_type):
        chiaki_log(log, CHIAKI_LOG_INFO, "Host Type:                         %s", host.host_type)

    if(host.host_id):
        chiaki_log(log, CHIAKI_LOG_INFO, "Host ID:                           %s", host.host_id)

    if(host.running_app_titleid):
        chiaki_log(log, CHIAKI_LOG_INFO, "Running App Title ID:              %s", host.running_app_titleid)

    if(host.running_app_name):
        chiaki_log(log, CHIAKI_LOG_INFO, "Running App Name:                  %s", host.running_app_name)

    chiaki_log(log, CHIAKI_LOG_INFO, "--")

    cbuser.discovery_is_running = 0


#Basically cythonized version of the chiaki-cli discovery function
def run_discovery():
    cdef ChiakiLog log
    chiaki_log_init(&log, CHIAKI_LOG_INFO | CHIAKI_LOG_ERROR | CHIAKI_LOG_DEBUG, chiaki_log_cb_print, NULL)

    cdef ChiakiDiscovery discovery
    cdef ChiakiErrorCode err
    err = chiaki_discovery_init(&discovery, &log, socket.AF_INET)
    if(err != CHIAKI_ERR_SUCCESS) :
        chiaki_log(&log, CHIAKI_LOG_ERROR, "Discovery init failed")
    else:
        chiaki_log(&log, CHIAKI_LOG_ERROR, "Discovery init succeeded")

    cdef ChiakiDiscoveryThread thread
    cdef DiscoveryCbData cbuser
    cbuser.log = &log
    cbuser.discovery_is_running = True
    err = chiaki_discovery_thread_start(&thread, &discovery, <ChiakiDiscoveryCb> discovery_cb, &cbuser)

    if(err != CHIAKI_ERR_SUCCESS):
        chiaki_log(&log, CHIAKI_LOG_ERROR, "Discovery thread init failed")
        chiaki_discovery_fini(&discovery)
        return 1

    addrinfos = socket.getaddrinfo("192.168.2.22", None, family=socket.AF_INET, proto=socket.IPPROTO_UDP) #Not sure why we bother with this, this whole mess needs rethinking and rewriting as I learn more about cython
    port = CHIAKI_DISCOVERY_PORT_PS5
    ipaddr = [int(i) for i in addrinfos[0][4][0].split('.')]
    print(ipaddr)
    cdef sockaddr host_addr
    memset(&host_addr, 0, sizeof(host_addr))
    host_addr.sa_family = socket.AF_INET
    #FIXME:  There has to be a cleaner way to do this...
    host_addrdata = struct.pack(">HBBBBxxxxxxxx", port, ipaddr[0], ipaddr[1], ipaddr[2], ipaddr[3])
    memcpy(host_addr.sa_data, <char *> host_addrdata, 14)


    cdef ChiakiDiscoveryPacket packet
    memset(&packet, 0, sizeof(packet))
    packet.cmd = CHIAKI_DISCOVERY_CMD_SRCH
    packet.protocol_version = CHIAKI_DISCOVERY_PROTOCOL_VERSION_PS5

    print("Sending discovery packet")
    err = chiaki_discovery_send(&discovery, &packet, &host_addr, sizeof(host_addr));
    if(err != CHIAKI_ERR_SUCCESS):
        chiaki_log(&log, CHIAKI_LOG_ERROR, "Failed to send discovery packet for PS5: {}".format(chiaki_error_string(err)))
    
    while(cbuser.discovery_is_running):
        sleep(0)