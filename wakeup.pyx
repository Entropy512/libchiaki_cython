from libchiaki cimport *
from libc.stdint cimport uint64_t

# https://stackoverflow.com/a/13976504 - WTF???
FOO = "Hi!"

def wakeup_host(host=None, regkey=None):
    cdef uint64_t int_regkey = <uint64_t> int(regkey,16)
    enchost = host.encode('UTF-8')
    cdef ChiakiLog log
    chiaki_log_init(&log, CHIAKI_LOG_INFO | CHIAKI_LOG_ERROR | CHIAKI_LOG_DEBUG, chiaki_log_cb_print, NULL)

    cdef bint is_ps5 = True

    chiaki_discovery_wakeup(&log, NULL, <char *> enchost, int_regkey, is_ps5)