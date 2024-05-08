from libc.stdint cimport uint64_t, uint8_t, uint32_t

cdef extern from "chiaki/gkcrypt.h":

    cdef struct chiaki_key_state_t:
        uint64_t prev

    ctypedef chiaki_key_state_t ChiakiKeyState

    cdef struct chiaki_gkcrypt_t:
        uint8_t index
        uint8_t* key_buf
        size_t key_buf_size
        size_t key_buf_populated
        uint64_t key_buf_key_pos_min
        size_t key_buf_start_offset
        uint64_t last_key_pos
        bool key_buf_thread_stop
        ChiakiMutex key_buf_mutex
        ChiakiCond key_buf_cond
        ChiakiThread key_buf_thread
        uint8_t iv[0x10]
        uint8_t key_base[0x10]
        uint8_t key_gmac_base[0x10]
        uint8_t key_gmac_current[0x10]
        uint64_t key_gmac_index_current
        ChiakiLog* log

    ctypedef chiaki_gkcrypt_t ChiakiGKCrypt

    cdef struct chiaki_session_t

    ChiakiErrorCode chiaki_gkcrypt_init(ChiakiGKCrypt* gkcrypt, ChiakiLog* log, size_t key_buf_chunks, uint8_t index, const uint8_t* handshake_key, const uint8_t* ecdh_secret)

    void chiaki_gkcrypt_fini(ChiakiGKCrypt* gkcrypt)

    ChiakiErrorCode chiaki_gkcrypt_gen_key_stream(ChiakiGKCrypt* gkcrypt, uint64_t key_pos, uint8_t* buf, size_t buf_size)

    ChiakiErrorCode chiaki_gkcrypt_get_key_stream(ChiakiGKCrypt* gkcrypt, uint64_t key_pos, uint8_t* buf, size_t buf_size)

    ChiakiErrorCode chiaki_gkcrypt_decrypt(ChiakiGKCrypt* gkcrypt, uint64_t key_pos, uint8_t* buf, size_t buf_size)

    ChiakiErrorCode chiaki_gkcrypt_encrypt(ChiakiGKCrypt* gkcrypt, uint64_t key_pos, uint8_t* buf, size_t buf_size)

    void chiaki_gkcrypt_gen_gmac_key(uint64_t index, const uint8_t* key_base, const uint8_t* iv, uint8_t* key_out)

    void chiaki_gkcrypt_gen_new_gmac_key(ChiakiGKCrypt* gkcrypt, uint64_t index)

    void chiaki_gkcrypt_gen_tmp_gmac_key(ChiakiGKCrypt* gkcrypt, uint64_t index, uint8_t* key_out)

    ChiakiErrorCode chiaki_gkcrypt_gmac(ChiakiGKCrypt* gkcrypt, uint64_t key_pos, const uint8_t* buf, size_t buf_size, uint8_t* gmac_out)

    ChiakiGKCrypt* chiaki_gkcrypt_new(ChiakiLog* log, size_t key_buf_chunks, uint8_t index, const uint8_t* handshake_key, const uint8_t* ecdh_secret)

    void chiaki_gkcrypt_free(ChiakiGKCrypt* gkcrypt)

    void chiaki_key_state_init(ChiakiKeyState* state)

    uint64_t chiaki_key_state_request_pos(ChiakiKeyState* state, uint32_t low, bool commit)

    void chiaki_key_state_commit(ChiakiKeyState* state, uint64_t prev)
