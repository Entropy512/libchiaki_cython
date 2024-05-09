#ifndef LIBCHIAKI_H
#define LIBCHIAKI_H

#include "chiaki/common.h"
#include "chiaki/log.h" // This only includes common.h - so the common include is technically redundant but that makes this easier to track
#include "chiaki/controller.h" //This only includes common.h and we want most of the stuff in it
#include "chiaki/orientation.h" // only includes controller and common, it's small, and does get used by the GUI
#include "chiaki/seqnum.h" // Only includes common, and is small

#include <sys/socket.h>

//thread.h, only including typedefs depended upon by discovery.h and session.h
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

typedef struct chiaki_mutex_t
{
#ifdef _WIN32
	CRITICAL_SECTION cs;
#else
	pthread_mutex_t mutex;
#endif
} ChiakiMutex;

typedef struct chiaki_cond_t
{
#ifdef _WIN32
	CONDITION_VARIABLE cond;
#else
	pthread_cond_t cond;
#endif
} ChiakiCond;

typedef struct chiaki_bool_pred_cond_t
{
	ChiakiCond cond;
	ChiakiMutex mutex;
	bool pred;
} ChiakiBoolPredCond;

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

//sock.h - discovery.h depends on this
#ifdef _WIN32
#include <winsock2.h>
typedef SOCKET chiaki_socket_t;
#define CHIAKI_SOCKET_IS_INVALID(s) ((s) == INVALID_SOCKET)
#define CHIAKI_INVALID_SOCKET INVALID_SOCKET
#define CHIAKI_SOCKET_CLOSE(s) closesocket(s)
#define CHIAKI_SOCKET_ERROR_FMT "%d"
#define CHIAKI_SOCKET_ERROR_VALUE (WSAGetLastError())
#define CHIAKI_SOCKET_EINPROGRESS (WSAGetLastError() == WSAEWOULDBLOCK)
#else
#include <unistd.h>
#include <errno.h>
typedef int chiaki_socket_t;
#define CHIAKI_SOCKET_IS_INVALID(s) ((s) < 0)
#define CHIAKI_INVALID_SOCKET (-1)
#define CHIAKI_SOCKET_CLOSE(s) close(s)
#define CHIAKI_SOCKET_ERROR_FMT "%s"
#define CHIAKI_SOCKET_ERROR_VALUE (strerror(errno))
#define CHIAKI_SOCKET_EINPROGRESS (errno == EINPROGRESS)
#endif

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

/**
 * Apply A on all names of string members in ChiakiDiscoveryHost
 */
#define CHIAKI_DISCOVERY_HOST_STRING_FOREACH(A) \
	A(host_addr); \
	A(system_version); \
	A(device_discovery_protocol_version); \
	A(host_name); \
	A(host_type); \
	A(host_id); \
	A(running_app_titleid); \
	A(running_app_name);

typedef struct chiaki_discovery_host_t
{
	// All string members here must be in sync with CHIAKI_DISCOVERY_HOST_STRING_FOREACH
	ChiakiDiscoveryHostState state;
	uint16_t host_request_port;
#define STRING_MEMBER(name) const char *name
	CHIAKI_DISCOVERY_HOST_STRING_FOREACH(STRING_MEMBER)
#undef STRING_MEMBER
} ChiakiDiscoveryHost;

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

/*
discoveryservice.h - only used by discoverymanager.cpp, determine later if we actually need this for a CLI application.
Most functions are used by discoverymanager so we're including the whole file
*/

typedef void (*ChiakiDiscoveryServiceCb)(ChiakiDiscoveryHost *hosts, size_t hosts_count, void *user);

typedef struct chiaki_discovery_service_options_t
{
	size_t hosts_max;
	uint64_t host_drop_pings;
	uint64_t ping_ms;
	struct sockaddr *send_addr;
	size_t send_addr_size;
	ChiakiDiscoveryServiceCb cb;
	void *cb_user;
} ChiakiDiscoveryServiceOptions;

typedef struct chiaki_discovery_service_host_discovery_info_t
{
	uint64_t last_ping_index;
} ChiakiDiscoveryServiceHostDiscoveryInfo;

typedef struct chiaki_discovery_service_t
{
	ChiakiLog *log;
	ChiakiDiscoveryServiceOptions options;
	ChiakiDiscovery discovery;

	uint64_t ping_index;
	ChiakiDiscoveryHost *hosts;
	ChiakiDiscoveryServiceHostDiscoveryInfo *host_discovery_infos;
	size_t hosts_count;
	ChiakiMutex state_mutex;

	ChiakiThread thread;
	ChiakiBoolPredCond stop_cond;
} ChiakiDiscoveryService;

CHIAKI_EXPORT ChiakiErrorCode chiaki_discovery_service_init(ChiakiDiscoveryService *service, ChiakiDiscoveryServiceOptions *options, ChiakiLog *log);
CHIAKI_EXPORT void chiaki_discovery_service_fini(ChiakiDiscoveryService *service);

//audio.h - only one struct is used by streamsession.cpp, no functions.  Basically a placeholder we'll pass to functions that insist on it and then ignore the result
typedef struct chiaki_audio_header_t
{
	uint8_t channels;
	uint8_t bits;
	uint32_t rate;
	uint32_t frame_size;
	uint32_t unknown;
} ChiakiAudioHeader;

//packetstats.h - ChiakiAudioReceiver needs this typedef
typedef struct chiaki_packet_stats_t
{
	ChiakiMutex mutex;

	// For generations of packets, i.e. where we know the number of expected packets per generation
	uint64_t gen_received;
	uint64_t gen_lost;

	// For sequential packets, i.e. where packets are identified by a sequence number
	ChiakiSeqNum16 seq_min; // sequence number that was max at the last reset
	ChiakiSeqNum16 seq_max; // currently maximal sequence number
	uint64_t seq_received; // total received packets since the last reset
} ChiakiPacketStats;

//audioreceiver.h - session.h and its dependencies have dependencies on this.  Another case of a placeholder struct that we won't do anything with because we plan on just dumping audio on the floor
typedef void (*ChiakiAudioSinkHeader)(ChiakiAudioHeader *header, void *user);
typedef void (*ChiakiAudioSinkFrame)(uint8_t *buf, size_t buf_size, void *user);

typedef struct chiaki_audio_sink_t
{
	void *user;
	ChiakiAudioSinkHeader header_cb;
	ChiakiAudioSinkFrame frame_cb;
} ChiakiAudioSink;

typedef struct chiaki_audio_receiver_t
{
	struct chiaki_session_t *session;
	ChiakiLog *log;
	ChiakiMutex mutex;
	ChiakiSeqNum16 frame_index_prev;
	bool frame_index_startup; // whether frame_index_prev has definitely not wrapped yet
	ChiakiPacketStats *packet_stats;
} ChiakiAudioReceiver;

//rpcrypt.h - we need the key size in session.h
#define CHIAKI_RPCRYPT_KEY_SIZE 0x10

typedef struct chiaki_rpcrypt_t
{
	ChiakiTarget target;
	uint8_t bright[CHIAKI_RPCRYPT_KEY_SIZE];
	uint8_t ambassador[CHIAKI_RPCRYPT_KEY_SIZE];
} ChiakiRPCrypt;

//ecdh.h - just the typedefs and a single define
#define CHIAKI_ECDH_SECRET_SIZE 32

typedef struct chiaki_ecdh_t
{
// the following lines may lead to memory corruption
// CHIAKI_LIB_ENABLE_MBEDTLS must be defined
// globally (whole project)
#ifdef CHIAKI_LIB_ENABLE_MBEDTLS
	// mbedtls ecdh context
	mbedtls_ecdh_context ctx;
	// deterministic random bit generator
	mbedtls_ctr_drbg_context drbg;
#else
	struct ec_group_st *group;
	struct ec_key_st *key_local;
#endif
} ChiakiECDH;

//ctrl.h - session.h depends on this typedef
typedef struct chiaki_ctrl_message_queue_t ChiakiCtrlMessageQueue;

struct chiaki_ctrl_message_queue_t
{
	ChiakiCtrlMessageQueue *next;
	uint16_t type;
	uint8_t *payload;
	size_t payload_size;
};

typedef struct chiaki_ctrl_t
{
	struct chiaki_session_t *session;
	ChiakiThread thread;

	bool should_stop;
	bool login_pin_entered;
	uint8_t *login_pin;
	size_t login_pin_size;
	ChiakiCtrlMessageQueue *msg_queue;
	ChiakiStopPipe notif_pipe;
	ChiakiMutex notif_mutex;

	bool login_pin_requested;

	chiaki_socket_t sock;

#ifdef __GNUC__
	__attribute__((aligned(__alignof__(uint32_t))))
#endif
	uint8_t recv_buf[512];

	size_t recv_buf_size;
	uint64_t crypt_counter_local;
	uint64_t crypt_counter_remote;
	uint32_t keyboard_text_counter;
} ChiakiCtrl;

//gkcrypt.h - streamconnection and others depend on this
#define CHIAKI_GKCRYPT_BLOCK_SIZE 0x10
#define CHIAKI_GKCRYPT_KEY_BUF_BLOCKS_DEFAULT 0x20 // 2MB
#define CHIAKI_GKCRYPT_GMAC_SIZE 4
#define CHIAKI_GKCRYPT_GMAC_KEY_REFRESH_KEY_POS 45000
#define CHIAKI_GKCRYPT_GMAC_KEY_REFRESH_IV_OFFSET 44910

typedef struct chiaki_key_state_t
{
   uint64_t prev;
} ChiakiKeyState;

typedef struct chiaki_gkcrypt_t {
	uint8_t index;

	uint8_t *key_buf; // circular buffer of the ctr mode key stream
	size_t key_buf_size;
	size_t key_buf_populated; // size of key_buf that is already populated (on startup)
	uint64_t key_buf_key_pos_min; // minimal key pos currently in key_buf
	size_t key_buf_start_offset; // offset in key_buf of the minimal key pos
	uint64_t last_key_pos;        // last key pos that has been requested
	bool key_buf_thread_stop;
	ChiakiMutex key_buf_mutex;
	ChiakiCond key_buf_cond;
	ChiakiThread key_buf_thread;

	uint8_t iv[CHIAKI_GKCRYPT_BLOCK_SIZE];
	uint8_t key_base[CHIAKI_GKCRYPT_BLOCK_SIZE];
	uint8_t key_gmac_base[CHIAKI_GKCRYPT_BLOCK_SIZE];
	uint8_t key_gmac_current[CHIAKI_GKCRYPT_BLOCK_SIZE];
	uint64_t key_gmac_index_current;
	ChiakiLog *log;
} ChiakiGKCrypt;

//reorderqueue.h - takion.h depends on this
typedef enum chiaki_reorder_queue_drop_strategy_t {
	CHIAKI_REORDER_QUEUE_DROP_STRATEGY_BEGIN, // drop packet with lowest number
	CHIAKI_REORDER_QUEUE_DROP_STRATEGY_END // drop packet with highest number
} ChiakiReorderQueueDropStrategy;

typedef struct chiaki_reorder_queue_entry_t
{
	void *user;
	bool set;
} ChiakiReorderQueueEntry;

typedef void (*ChiakiReorderQueueDropCb)(uint64_t seq_num, void *elem_user, void *cb_user);
typedef bool (*ChiakiReorderQueueSeqNumGt)(uint64_t a, uint64_t b);
typedef bool (*ChiakiReorderQueueSeqNumLt)(uint64_t a, uint64_t b);
typedef uint64_t (*ChiakiReorderQueueSeqNumAdd)(uint64_t a, uint64_t b);
typedef uint64_t (*ChiakiReorderQueueSeqNumSub)(uint64_t a, uint64_t b);

typedef struct chiaki_reorder_queue_t
{
	size_t size_exp; // real size = 2^size * sizeof(ChiakiReorderQueueEntry)
	ChiakiReorderQueueEntry *queue;
	uint64_t begin;
	uint64_t count;
	ChiakiReorderQueueSeqNumGt seq_num_gt;
	ChiakiReorderQueueSeqNumLt seq_num_lt;
	ChiakiReorderQueueSeqNumAdd seq_num_add;
	ChiakiReorderQueueSeqNumSub seq_num_sub;
	ChiakiReorderQueueDropStrategy drop_strategy;
	ChiakiReorderQueueDropCb drop_cb;
	void *drop_cb_user;
} ChiakiReorderQueue;

//takionsendbuffer.h - takion depends on this
typedef struct chiaki_takion_t ChiakiTakion;

typedef struct chiaki_takion_send_buffer_packet_t
{
	ChiakiSeqNum32 seq_num;
	uint64_t tries;
	uint64_t last_send_ms; // chiaki_time_now_monotonic_ms()
	uint8_t *buf;
	size_t buf_size;
} ChiakiTakionSendBufferPacket;

typedef struct chiaki_takion_send_buffer_t
{
	ChiakiLog *log;
	ChiakiTakion *takion;

	ChiakiTakionSendBufferPacket *packets;
	size_t packets_size; // allocated size
	size_t packets_count; // current count

	ChiakiMutex mutex;
	ChiakiCond cond;
	bool should_stop;
	ChiakiThread thread;
} ChiakiTakionSendBuffer;

//takion.h - streamconnection and some other things depend on its typedefs
typedef enum chiaki_takion_message_data_type_t {
	CHIAKI_TAKION_MESSAGE_DATA_TYPE_PROTOBUF = 0,
	CHIAKI_TAKION_MESSAGE_DATA_TYPE_RUMBLE = 7,
	CHIAKI_TAKION_MESSAGE_DATA_TYPE_9 = 9,
	CHIAKI_TAKION_MESSAGE_DATA_TYPE_TRIGGER_EFFECTS = 11,
} ChiakiTakionMessageDataType;

typedef struct chiaki_takion_av_packet_t
{
	ChiakiSeqNum16 packet_index;
	ChiakiSeqNum16 frame_index;
	bool uses_nalu_info_structs;
	bool is_video;
	bool is_haptics;
	ChiakiSeqNum16 unit_index;
	uint16_t units_in_frame_total; // source + units_in_frame_fec
	uint16_t units_in_frame_fec;
	uint8_t codec;
	uint16_t word_at_0x18;
	uint8_t adaptive_stream_index;
	uint8_t byte_at_0x2c;

	uint64_t key_pos;

	uint8_t *data; // not owned
	size_t data_size;
} ChiakiTakionAVPacket;

static inline uint8_t chiaki_takion_av_packet_audio_unit_size(ChiakiTakionAVPacket *packet)				{ return packet->units_in_frame_fec >> 8; }
static inline uint8_t chiaki_takion_av_packet_audio_source_units_count(ChiakiTakionAVPacket *packet)	{ return packet->units_in_frame_fec & 0xf; }
static inline uint8_t chiaki_takion_av_packet_audio_fec_units_count(ChiakiTakionAVPacket *packet)		{ return (packet->units_in_frame_fec >> 4) & 0xf; }

typedef ChiakiErrorCode (*ChiakiTakionAVPacketParse)(ChiakiTakionAVPacket *packet, ChiakiKeyState *key_state, uint8_t *buf, size_t buf_size);

typedef struct chiaki_takion_congestion_packet_t
{
	uint16_t word_0;
	uint16_t received;
	uint16_t lost;
} ChiakiTakionCongestionPacket;


typedef enum {
	CHIAKI_TAKION_EVENT_TYPE_CONNECTED,
	CHIAKI_TAKION_EVENT_TYPE_DISCONNECT,
	CHIAKI_TAKION_EVENT_TYPE_DATA,
	CHIAKI_TAKION_EVENT_TYPE_DATA_ACK,
	CHIAKI_TAKION_EVENT_TYPE_AV
} ChiakiTakionEventType;

typedef struct chiaki_takion_event_t
{
	ChiakiTakionEventType type;
	union
	{
		struct
		{
			ChiakiTakionMessageDataType data_type;
			uint8_t *buf;
			size_t buf_size;
		} data;

		struct
		{
			ChiakiSeqNum32 seq_num;
		} data_ack;

		ChiakiTakionAVPacket *av;
	};
} ChiakiTakionEvent;

typedef void (*ChiakiTakionCallback)(ChiakiTakionEvent *event, void *user);

typedef struct chiaki_takion_connect_info_t
{
	ChiakiLog *log;
	struct sockaddr *sa;
	size_t sa_len;
	bool ip_dontfrag;
	ChiakiTakionCallback cb;
	void *cb_user;
	bool enable_crypt;
	bool enable_dualsense;
	uint8_t protocol_version;
} ChiakiTakionConnectInfo;

typedef struct chiaki_takion_postponed_packet_t
{
	uint8_t *buf;
	size_t buf_size;
} ChiakiTakionPostponedPacket;

struct chiaki_takion_t
{
	ChiakiLog *log;
	uint8_t version;

	/**
	 * Whether encryption should be used.
	 *
	 * If false, encryption and MACs are disabled completely.
	 *
	 * If true, encryption and MACs will be used depending on whether gkcrypt_local and gkcrypt_remote are non-null, respectively.
	 * However, if gkcrypt_remote is null, only control data packets are passed to the callback and all other packets are postponed until
	 * gkcrypt_remote is set, so it has been set, so eventually all MACs will be checked.
	 */
	bool enable_crypt;

	/**
	 * Array to be temporarily allocated when non-data packets come, enable_crypt is true, but gkcrypt_remote is NULL
	 * to not ignore any MACs in this period.
	 */
	struct chiaki_takion_postponed_packet_t *postponed_packets;
	size_t postponed_packets_size;
	size_t postponed_packets_count;

	ChiakiGKCrypt *gkcrypt_local; // if NULL (default), no gmac is calculated and nothing is encrypted
	uint64_t key_pos_local;
	ChiakiMutex gkcrypt_local_mutex;

	ChiakiGKCrypt *gkcrypt_remote; // if NULL (default), remote gmacs are IGNORED (!) and everything is expected to be unencrypted

	ChiakiReorderQueue data_queue;
	ChiakiTakionSendBuffer send_buffer;

	ChiakiTakionCallback cb;
	void *cb_user;
	chiaki_socket_t sock;
	ChiakiThread thread;
	ChiakiStopPipe stop_pipe;
	uint32_t tag_local;
	uint32_t tag_remote;

	ChiakiSeqNum32 seq_num_local;
	ChiakiMutex seq_num_local_mutex;

	/**
	 * Advertised Receiver Window Credit
	 */
	uint32_t a_rwnd;

	ChiakiTakionAVPacketParse av_packet_parse;

	ChiakiKeyState key_state;

	bool enable_dualsense;
};

//videoprofile.h - videoreceiveer.h depends on this typedef
typedef struct chiaki_video_profile_t
{
	unsigned int width;
	unsigned int height;
	size_t header_sz;
	uint8_t *header;
} ChiakiVideoProfile;

//frameprocessor.h - videoreceiver.h depends on these typedefs
typedef struct chiaki_stream_stats_t
{
	uint64_t frames;
	uint64_t bytes;
} ChiakiStreamStats;

struct chiaki_frame_unit_t;
typedef struct chiaki_frame_unit_t ChiakiFrameUnit;

typedef struct chiaki_frame_processor_t
{
	ChiakiLog *log;
	uint8_t *frame_buf;
	size_t frame_buf_size;
	size_t buf_size_per_unit;
	size_t buf_stride_per_unit;
	unsigned int units_source_expected;
	unsigned int units_fec_expected;
	unsigned int units_source_received;
	unsigned int units_fec_received;
	ChiakiFrameUnit *unit_slots;
	size_t unit_slots_size;
	bool flushed; // whether we have already flushed the current frame, i.e. are only interested in stats, not data.
	ChiakiStreamStats stream_stats;
} ChiakiFrameProcessor;

//videoreceiver.h - placeholder typedef that we'll just ignore the contents of
#define CHIAKI_VIDEO_PROFILES_MAX 8

typedef struct chiaki_video_receiver_t
{
	struct chiaki_session_t *session;
	ChiakiLog *log;
	ChiakiVideoProfile profiles[CHIAKI_VIDEO_PROFILES_MAX];
	size_t profiles_count;
	int profile_cur; // < 1 if no profile selected yet, else index in profiles

	int32_t frame_index_cur; // frame that is currently being filled
	int32_t frame_index_prev; // last frame that has been at least partially decoded
	int32_t frame_index_prev_complete; // last frame that has been completely decoded
	ChiakiFrameProcessor frame_processor;
	ChiakiPacketStats *packet_stats;
} ChiakiVideoReceiver;

//feedback.h - feedbacksender needs a typedef here but we also might want FeedbackState just in case
typedef struct chiaki_feedback_state_t
{
	float gyro_x, gyro_y, gyro_z;
	float accel_x, accel_y, accel_z;
	float orient_x, orient_y, orient_z, orient_w;
	int16_t left_x;
	int16_t left_y;
	int16_t right_x;
	int16_t right_y;
} ChiakiFeedbackState;

#define CHIAKI_HISTORY_EVENT_SIZE_MAX 0x5

typedef struct chiaki_feedback_history_event_t
{
	uint8_t buf[CHIAKI_HISTORY_EVENT_SIZE_MAX];
	size_t len;
} ChiakiFeedbackHistoryEvent;

typedef struct chiaki_feedback_history_buffer_t
{
	ChiakiFeedbackHistoryEvent *events;
	size_t size;
	size_t begin;
	size_t len;
} ChiakiFeedbackHistoryBuffer;

//feedbacksender.h - streamconnection.h depends on this typedef
typedef struct chiaki_feedback_sender_t
{
	ChiakiLog *log;
	ChiakiTakion *takion;
	ChiakiThread thread;

	ChiakiSeqNum16 state_seq_num;

	ChiakiSeqNum16 history_seq_num;
	ChiakiFeedbackHistoryBuffer history_buf;

	bool should_stop;
	ChiakiControllerState controller_state_prev;
	ChiakiControllerState controller_state;
	bool controller_state_changed;
	ChiakiMutex state_mutex;
	ChiakiCond state_cond;
} ChiakiFeedbackSender;

//streamconnection.h - session.h depends on this typedef
typedef struct chiaki_stream_connection_t
{
	struct chiaki_session_t *session;
	ChiakiLog *log;
	ChiakiTakion takion;
	uint8_t *ecdh_secret;
	ChiakiGKCrypt *gkcrypt_local;
	ChiakiGKCrypt *gkcrypt_remote;

	ChiakiPacketStats packet_stats;
	ChiakiAudioReceiver *audio_receiver;
	ChiakiVideoReceiver *video_receiver;
	ChiakiAudioReceiver *haptics_receiver;

	ChiakiFeedbackSender feedback_sender;
	/**
	 * whether feedback_sender is initialized
	 * only if this is true, feedback_sender may be accessed!
	 */
	bool feedback_sender_active;
	/**
	 * protects feedback_sender and feedback_sender_active
	 */
	ChiakiMutex feedback_sender_mutex;

	/**
	 * signaled on change of state_finished or should_stop
	 */
	ChiakiCond state_cond;

	/**
	 * protects state, state_finished, state_failed and should_stop
	 */
	ChiakiMutex state_mutex;

	int state;
	bool state_finished;
	bool state_failed;
	bool should_stop;
	bool remote_disconnected;
	char *remote_disconnect_reason;
} ChiakiStreamConnection;


/*
 * session.h - this has a MASSIVE include tree, so we'll just include its contents and then add minimal typedefs for its dependencies above.  We probably need nearly all of it externally.
 * Opportunity to slim it down later
 */

#define CHIAKI_RP_APPLICATION_REASON_REGIST_FAILED		0x80108b09
#define CHIAKI_RP_APPLICATION_REASON_INVALID_PSN_ID		0x80108b02
#define CHIAKI_RP_APPLICATION_REASON_IN_USE				0x80108b10
#define CHIAKI_RP_APPLICATION_REASON_CRASH				0x80108b15
#define CHIAKI_RP_APPLICATION_REASON_RP_VERSION			0x80108b11
#define CHIAKI_RP_APPLICATION_REASON_UNKNOWN			0x80108bff

CHIAKI_EXPORT const char *chiaki_rp_application_reason_string(uint32_t reason);

/**
 * @return RP-Version string or NULL
 */
CHIAKI_EXPORT const char *chiaki_rp_version_string(ChiakiTarget target);

CHIAKI_EXPORT ChiakiTarget chiaki_rp_version_parse(const char *rp_version_str, bool is_ps5);


#define CHIAKI_RP_DID_SIZE 32
#define CHIAKI_SESSION_ID_SIZE_MAX 80
#define CHIAKI_HANDSHAKE_KEY_SIZE 0x10

typedef struct chiaki_connect_video_profile_t
{
	unsigned int width;
	unsigned int height;
	unsigned int max_fps;
	unsigned int bitrate;
	ChiakiCodec codec;
} ChiakiConnectVideoProfile;

typedef enum {
	// values must not change
	CHIAKI_VIDEO_RESOLUTION_PRESET_360p = 1,
	CHIAKI_VIDEO_RESOLUTION_PRESET_540p = 2,
	CHIAKI_VIDEO_RESOLUTION_PRESET_720p = 3,
	CHIAKI_VIDEO_RESOLUTION_PRESET_1080p = 4
} ChiakiVideoResolutionPreset;

typedef enum {
	// values must not change
	CHIAKI_VIDEO_FPS_PRESET_30 = 30,
	CHIAKI_VIDEO_FPS_PRESET_60 = 60
} ChiakiVideoFPSPreset;

CHIAKI_EXPORT void chiaki_connect_video_profile_preset(ChiakiConnectVideoProfile *profile, ChiakiVideoResolutionPreset resolution, ChiakiVideoFPSPreset fps);

#define CHIAKI_SESSION_AUTH_SIZE 0x10

typedef struct chiaki_connect_info_t
{
	bool ps5;
	const char *host; // null terminated
	char regist_key[CHIAKI_SESSION_AUTH_SIZE]; // must be completely filled (pad with \0)
	uint8_t morning[0x10];
	ChiakiConnectVideoProfile video_profile;
	bool video_profile_auto_downgrade; // Downgrade video_profile if server does not seem to support it.
	bool enable_keyboard;
	bool enable_dualsense;
} ChiakiConnectInfo;


typedef enum {
	CHIAKI_QUIT_REASON_NONE,
	CHIAKI_QUIT_REASON_STOPPED,
	CHIAKI_QUIT_REASON_SESSION_REQUEST_UNKNOWN,
	CHIAKI_QUIT_REASON_SESSION_REQUEST_CONNECTION_REFUSED,
	CHIAKI_QUIT_REASON_SESSION_REQUEST_RP_IN_USE,
	CHIAKI_QUIT_REASON_SESSION_REQUEST_RP_CRASH,
	CHIAKI_QUIT_REASON_SESSION_REQUEST_RP_VERSION_MISMATCH,
	CHIAKI_QUIT_REASON_CTRL_UNKNOWN,
	CHIAKI_QUIT_REASON_CTRL_CONNECT_FAILED,
	CHIAKI_QUIT_REASON_CTRL_CONNECTION_REFUSED,
	CHIAKI_QUIT_REASON_STREAM_CONNECTION_UNKNOWN,
	CHIAKI_QUIT_REASON_STREAM_CONNECTION_REMOTE_DISCONNECTED,
	CHIAKI_QUIT_REASON_STREAM_CONNECTION_REMOTE_SHUTDOWN, // like REMOTE_DISCONNECTED, but because the server shut down
} ChiakiQuitReason;

CHIAKI_EXPORT const char *chiaki_quit_reason_string(ChiakiQuitReason reason);

static inline bool chiaki_quit_reason_is_error(ChiakiQuitReason reason)
{
	return reason != CHIAKI_QUIT_REASON_STOPPED && reason != CHIAKI_QUIT_REASON_STREAM_CONNECTION_REMOTE_SHUTDOWN;
}

typedef struct chiaki_quit_event_t
{
	ChiakiQuitReason reason;
	const char *reason_str;
} ChiakiQuitEvent;

typedef struct chiaki_keyboard_event_t
{
	const char *text_str;
} ChiakiKeyboardEvent;

typedef struct chiaki_audio_stream_info_event_t
{
	ChiakiAudioHeader audio_header;
} ChiakiAudioStreamInfoEvent;

typedef struct chiaki_rumble_event_t
{
	uint8_t unknown;
	uint8_t left; // low-frequency
	uint8_t right; // high-frequency
} ChiakiRumbleEvent;

typedef struct chiaki_trigger_effects_event_t
{
	uint8_t type_left;
	uint8_t type_right;
	uint8_t left[10];
	uint8_t right[10];
} ChiakiTriggerEffectsEvent;

typedef enum {
	CHIAKI_EVENT_CONNECTED,
	CHIAKI_EVENT_LOGIN_PIN_REQUEST,
	CHIAKI_EVENT_KEYBOARD_OPEN,
	CHIAKI_EVENT_KEYBOARD_TEXT_CHANGE,
	CHIAKI_EVENT_KEYBOARD_REMOTE_CLOSE,
	CHIAKI_EVENT_RUMBLE,
	CHIAKI_EVENT_QUIT,
	CHIAKI_EVENT_TRIGGER_EFFECTS,
} ChiakiEventType;

typedef struct chiaki_event_t
{
	ChiakiEventType type;
	union
	{
		ChiakiQuitEvent quit;
		ChiakiKeyboardEvent keyboard;
		ChiakiRumbleEvent rumble;
		ChiakiTriggerEffectsEvent trigger_effects;
		struct
		{
			bool pin_incorrect; // false on first request, true if the pin entered before was incorrect
		} login_pin_request;
	};
} ChiakiEvent;

typedef void (*ChiakiEventCallback)(ChiakiEvent *event, void *user);

/**
 * buf will always have an allocated padding of at least CHIAKI_VIDEO_BUFFER_PADDING_SIZE after buf_size
 * @return whether the sample was successfully pushed into the decoder. On false, a corrupt frame will be reported to get a new keyframe.
 */
typedef bool (*ChiakiVideoSampleCallback)(uint8_t *buf, size_t buf_size, void *user);



typedef struct chiaki_session_t
{
	struct
	{
		bool ps5;
		struct addrinfo *host_addrinfos;
		struct addrinfo *host_addrinfo_selected;
		char hostname[256];
		char regist_key[CHIAKI_RPCRYPT_KEY_SIZE];
		uint8_t morning[CHIAKI_RPCRYPT_KEY_SIZE];
		uint8_t did[CHIAKI_RP_DID_SIZE];
		ChiakiConnectVideoProfile video_profile;
		bool video_profile_auto_downgrade;
		bool enable_keyboard;
		bool enable_dualsense;
	} connect_info;

	ChiakiTarget target;

	uint8_t nonce[CHIAKI_RPCRYPT_KEY_SIZE];
	ChiakiRPCrypt rpcrypt;
	char session_id[CHIAKI_SESSION_ID_SIZE_MAX]; // zero-terminated
	uint8_t handshake_key[CHIAKI_HANDSHAKE_KEY_SIZE];
	uint32_t mtu_in;
	uint32_t mtu_out;
	uint64_t rtt_us;
	ChiakiECDH ecdh;

	ChiakiQuitReason quit_reason;
	char *quit_reason_str; // additional reason string from remote

	ChiakiEventCallback event_cb;
	void *event_cb_user;
	ChiakiVideoSampleCallback video_sample_cb;
	void *video_sample_cb_user;
	ChiakiAudioSink audio_sink;
	ChiakiAudioSink haptics_sink;

	ChiakiThread session_thread;

	ChiakiCond state_cond;
	ChiakiMutex state_mutex;
	ChiakiStopPipe stop_pipe;
	bool should_stop;
	bool ctrl_failed;
	bool ctrl_session_id_received;
	bool ctrl_login_pin_requested;
	bool login_pin_entered;
	uint8_t *login_pin;
	size_t login_pin_size;

	ChiakiCtrl ctrl;

	ChiakiLog *log;

	ChiakiStreamConnection stream_connection;

	ChiakiControllerState controller_state;
} ChiakiSession;

CHIAKI_EXPORT ChiakiErrorCode chiaki_session_init(ChiakiSession *session, ChiakiConnectInfo *connect_info, ChiakiLog *log);
CHIAKI_EXPORT void chiaki_session_fini(ChiakiSession *session);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_start(ChiakiSession *session);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_stop(ChiakiSession *session);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_join(ChiakiSession *session);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_set_controller_state(ChiakiSession *session, ChiakiControllerState *state);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_set_login_pin(ChiakiSession *session, const uint8_t *pin, size_t pin_size);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_goto_bed(ChiakiSession *session);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_keyboard_set_text(ChiakiSession *session, const char *text);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_keyboard_reject(ChiakiSession *session);
CHIAKI_EXPORT ChiakiErrorCode chiaki_session_keyboard_accept(ChiakiSession *session);

static inline void chiaki_session_set_event_cb(ChiakiSession *session, ChiakiEventCallback cb, void *user)
{
	session->event_cb = cb;
	session->event_cb_user = user;
}

static inline void chiaki_session_set_video_sample_cb(ChiakiSession *session, ChiakiVideoSampleCallback cb, void *user)
{
	session->video_sample_cb = cb;
	session->video_sample_cb_user = user;
}

/**
 * @param sink contents are copied
 */
static inline void chiaki_session_set_audio_sink(ChiakiSession *session, ChiakiAudioSink *sink)
{
	session->audio_sink = *sink;
}

/**
 * @param sink contents are copied
 */
static inline void chiaki_session_set_haptics_sink(ChiakiSession *session, ChiakiAudioSink *sink)
{
	session->haptics_sink = *sink;
}

//regist.h - this has a really deep include tree so we'll include its contents but not include the original header which will pull in a bunch of things we do not want
#define CHIAKI_PSN_ACCOUNT_ID_SIZE 8

typedef struct chiaki_regist_info_t
{
	ChiakiTarget target;
	const char *host;
	bool broadcast;

	/**
	 * may be null, in which case psn_account_id will be used
	 */
	const char *psn_online_id;

	/**
	 * will be used if psn_online_id is null, for PS4 >= 7.0
	 */
	uint8_t psn_account_id[CHIAKI_PSN_ACCOUNT_ID_SIZE];

	uint32_t pin;
} ChiakiRegistInfo;

typedef struct chiaki_registered_host_t
{
	ChiakiTarget target;
	char ap_ssid[0x30];
	char ap_bssid[0x20];
	char ap_key[0x50];
	char ap_name[0x20];
	uint8_t server_mac[6];
	char server_nickname[0x20];
	char rp_regist_key[CHIAKI_SESSION_AUTH_SIZE]; // must be completely filled (pad with \0)
	uint32_t rp_key_type;
	uint8_t rp_key[0x10];
} ChiakiRegisteredHost;

typedef enum chiaki_regist_event_type_t {
	CHIAKI_REGIST_EVENT_TYPE_FINISHED_CANCELED,
	CHIAKI_REGIST_EVENT_TYPE_FINISHED_FAILED,
	CHIAKI_REGIST_EVENT_TYPE_FINISHED_SUCCESS
} ChiakiRegistEventType;

typedef struct chiaki_regist_event_t
{
	ChiakiRegistEventType type;
	ChiakiRegisteredHost *registered_host;
} ChiakiRegistEvent;

typedef void (*ChiakiRegistCb)(ChiakiRegistEvent *event, void *user);

typedef struct chiaki_regist_t
{
	ChiakiLog *log;
	ChiakiRegistInfo info;
	ChiakiRegistCb cb;
	void *cb_user;

	ChiakiThread thread;
	ChiakiStopPipe stop_pipe;
} ChiakiRegist;

CHIAKI_EXPORT ChiakiErrorCode chiaki_regist_start(ChiakiRegist *regist, ChiakiLog *log, const ChiakiRegistInfo *info, ChiakiRegistCb cb, void *cb_user);
CHIAKI_EXPORT void chiaki_regist_fini(ChiakiRegist *regist);
CHIAKI_EXPORT void chiaki_regist_stop(ChiakiRegist *regist);

/**
 * @param psn_account_id must be exactly of size CHIAKI_PSN_ACCOUNT_ID_SIZE
 */
CHIAKI_EXPORT ChiakiErrorCode chiaki_regist_request_payload_format(ChiakiTarget target, const uint8_t *ambassador, uint8_t *buf, size_t *buf_size, ChiakiRPCrypt *crypt, const char *psn_online_id, const uint8_t *psn_account_id, uint32_t pin);

#endif