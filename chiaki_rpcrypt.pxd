from libc.stdint cimport uint8_t, uint32_t, uint64_t

cdef extern from "chiaki/rpcrypt.h":

    cdef struct chiaki_rpcrypt_t:
        ChiakiTarget target
        uint8_t bright[0x10]
        uint8_t ambassador[0x10]

    ctypedef chiaki_rpcrypt_t ChiakiRPCrypt

    void chiaki_rpcrypt_bright_ambassador(ChiakiTarget target, uint8_t* bright, uint8_t* ambassador, const uint8_t* nonce, const uint8_t* morning)

    void chiaki_rpcrypt_aeropause_ps4_pre10(uint8_t* aeropause, const uint8_t* ambassador)

    ChiakiErrorCode chiaki_rpcrypt_aeropause(ChiakiTarget target, size_t key_1_off, uint8_t* aeropause, const uint8_t* ambassador)

    void chiaki_rpcrypt_init_auth(ChiakiRPCrypt* rpcrypt, ChiakiTarget target, const uint8_t* nonce, const uint8_t* morning)

    void chiaki_rpcrypt_init_regist_ps4_pre10(ChiakiRPCrypt* rpcrypt, const uint8_t* ambassador, uint32_t pin)

    ChiakiErrorCode chiaki_rpcrypt_init_regist(ChiakiRPCrypt* rpcrypt, ChiakiTarget target, const uint8_t* ambassador, size_t key_0_off, uint32_t pin)

    ChiakiErrorCode chiaki_rpcrypt_generate_iv(ChiakiRPCrypt* rpcrypt, uint8_t* iv, uint64_t counter)

    ChiakiErrorCode chiaki_rpcrypt_encrypt(ChiakiRPCrypt* rpcrypt, uint64_t counter, const uint8_t* in_, uint8_t* out, size_t sz)

    ChiakiErrorCode chiaki_rpcrypt_decrypt(ChiakiRPCrypt* rpcrypt, uint64_t counter, const uint8_t* in_, uint8_t* out, size_t sz)
