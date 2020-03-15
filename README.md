# ProjectC

Learning cryptography in Erlang

## Done

* RSA size = 4096, exponent = 65537, padding = rsa_pkcs1_oaep_padding
  * create keypairs
  * import to PEM
  * export from PEM
  * encrypt with a public key
  * decrypt with a private key
* AES 256 GCM (Galois/Counter Mode), key length = 32, IV bytesize = 12, auth tag length = 16
  * create keys
  * encrypt
  * decrypt
* Derive keys with PBKDF2 HMAC to use with AES 256 GCM
