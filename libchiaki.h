#ifndef LIBCHIAKI_H
#define LIBCHIAKI_H

#include "chiaki/common.h"
#include "chiaki/log.h" // This only includes common.h - so the common include is technically redundant but that makes this easier to track
#include "chiaki/controller.h" //This only includes common.h and we want most of the stuff in it

//thread.h, only including a single struct def from there, this is the only dependency discovery.h has
typedef struct chiaki_thread_t
{
#ifdef _WIN32
	HANDLE thread;
	ChiakiThreadFunc func;
	void *arg;
	void *ret;
#else
	pthread_t thread;
#endif
} ChiakiThread;

//stoppipe.h, only including a single struct that discovery.h depends on
typedef struct chiaki_stop_pipe_t
{
#ifdef _WIN32
	WSAEVENT event;
#elif defined(__SWITCH__)
	// due to a lack pipe/event/socketpair
	// on switch env, we use a physical socket
	// to send/trigger the cancel signal
	struct sockaddr_in addr;
	// local stop socket file descriptor
	// this fd is audited by 'select' as
	// fd_set *readfds
	int fd;
#else
	int fds[2];
#endif
} ChiakiStopPipe;

//discovery.h, determine how much we can remove later
#define CHIAKI_DISCOVERY_PORT_PS4 987
#define CHIAKI_DISCOVERY_PROTOCOL_VERSION_PS4 "00020020"
#define CHIAKI_DISCOVERY_PORT_PS5 9302
#define CHIAKI_DISCOVERY_PROTOCOL_VERSION_PS5 "00030010"
#define CHIAKI_DISCOVERY_PORT_LOCAL_MIN 9303
#define CHIAKI_DISCOVERY_PORT_LOCAL_MAX 9319

typedef enum chiaki_discovery_cmd_t
{
	CHIAKI_DISCOVERY_CMD_SRCH,
	CHIAKI_DISCOVERY_CMD_WAKEUP
} ChiakiDiscoveryCmd;

typedef struct chiaki_discovery_packet_t
{
	ChiakiDiscoveryCmd cmd;
	char *protocol_version;
	uint64_t user_credential; // for wakeup, this is just the regist key interpreted as hex
} ChiakiDiscoveryPacket;

typedef enum chiaki_discovery_host_state_t
{
	CHIAKI_DISCOVERY_HOST_STATE_UNKNOWN,
	CHIAKI_DISCOVERY_HOST_STATE_READY,
	CHIAKI_DISCOVERY_HOST_STATE_STANDBY
} ChiakiDiscoveryHostState;

typedef struct chiaki_discovery_t
{
	ChiakiLog *log;
	chiaki_socket_t socket;
	struct sockaddr local_addr;
} ChiakiDiscovery;

CHIAKI_EXPORT ChiakiErrorCode chiaki_discovery_init(ChiakiDiscovery *discovery, ChiakiLog *log, sa_family_t family);
CHIAKI_EXPORT void chiaki_discovery_fini(ChiakiDiscovery *discovery);
CHIAKI_EXPORT ChiakiErrorCode chiaki_discovery_send(ChiakiDiscovery *discovery, ChiakiDiscoveryPacket *packet, struct sockaddr *addr, size_t addr_size);

// GUI doesn't use this but CLI does
typedef void (*ChiakiDiscoveryCb)(ChiakiDiscoveryHost *host, void *user);

typedef struct chiaki_discovery_thread_t
{
	ChiakiDiscovery *discovery;
	ChiakiThread thread;
	ChiakiStopPipe stop_pipe;
	ChiakiDiscoveryCb cb;
	void *cb_user;
} ChiakiDiscoveryThread;

CHIAKI_EXPORT ChiakiErrorCode chiaki_discovery_thread_start(ChiakiDiscoveryThread *thread, ChiakiDiscovery *discovery, ChiakiDiscoveryCb cb, void *cb_user);
CHIAKI_EXPORT ChiakiErrorCode chiaki_discovery_thread_stop(ChiakiDiscoveryThread *thread);

//audio.h - only one struct is used by streamsession.cpp, no functions
typedef struct chiaki_audio_header_t
{
	uint8_t channels;
	uint8_t bits;
	uint32_t rate;
	uint32_t frame_size;
	uint32_t unknown;
} ChiakiAudioHeader;


#endif