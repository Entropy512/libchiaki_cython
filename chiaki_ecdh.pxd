from libc.stdint cimport uint8_t

cdef extern from "chiaki/ecdh.h":

    cdef struct chiaki_ecdh_t:
        ec_group_st* group
        ec_key_st* key_local

    ctypedef chiaki_ecdh_t ChiakiECDH

    ChiakiErrorCode chiaki_ecdh_init(ChiakiECDH* ecdh)

    void chiaki_ecdh_fini(ChiakiECDH* ecdh)

    ChiakiErrorCode chiaki_ecdh_get_local_pub_key(ChiakiECDH* ecdh, uint8_t* key_out, size_t* key_out_size, const uint8_t* handshake_key, uint8_t* sig_out, size_t* sig_out_size)

    ChiakiErrorCode chiaki_ecdh_derive_secret(ChiakiECDH* ecdh, uint8_t* secret_out, const uint8_t* remote_key, size_t remote_key_size, const uint8_t* handshake_key, const uint8_t* remote_sig, size_t remote_sig_size)

    ChiakiErrorCode chiaki_ecdh_set_local_key(ChiakiECDH* ecdh, const uint8_t* private_key, size_t private_key_size, const uint8_t* public_key, size_t public_key_size)
