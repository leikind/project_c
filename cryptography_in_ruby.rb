#!/usr/bin/env ruby

require 'bundler/inline'
# require 'base64'

gemfile do
  gem 'cryppo', github: 'Meeco/cryppo'
end

def openssl_ciphers
  # '<name>-<key length>-<mode>'
  p OpenSSL::Cipher.ciphers
end

# Rsa4096: keypair gen, public_encrypt, private_decrypt, to_pem, from_pem
def rsa4096
  input = 'this is love'

  rsa_key = OpenSSL::PKey::RSA.new(4096)
  # p rsa_key #=> OpenSSL::PKey::RSA

  rsa_public_key = rsa_key.public_key
  # p rsa_public_key #=> OpenSSL::PKey::RSA

  pem = rsa_key.to_pem
  # puts pem

  # padding defaults to PKCS1_PADDING
  encrypted_data = rsa_public_key.public_encrypt(input, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)

  # p encrypted_data

  rsa_key_restored = OpenSSL::PKey::RSA.new(pem)

  decrypted = rsa_key_restored.private_decrypt(encrypted_data, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
  puts
  puts decrypted
end

# legacy in Cryppo, not needed
def aes256Ofb
  # === === encrypt === ===

  cipher = OpenSSL::Cipher::AES.new(256, :OFB)
  # p cipher.key_len #=> 32
  # Generate a random key with OpenSSL::Random.random_bytes and
  # sets it to the cipher, and returns it
  key = cipher.random_key

  # Initializes the Cipher for encryption.
  cipher.encrypt

  # Generate a random IV with OpenSSL::Random.random_bytes and sets it to the cipher,
  # p cipher.iv_len #=> 16
  iv = cipher.random_iv
  puts 'iv'
  p iv

  # Returns the remaining data held in the cipher object.
  # Further calls to #update or #final will return garbage.
  # This call should always be made as the last call of an encryption or
  # decryption operation, after after having fed the entire plaintext
  # or ciphertext to the Cipher instance.
  encrypted_data = cipher.update('I love you') + cipher.final
  p 'encrypted_data'
  p encrypted_data

  # === === decrypt === ===

  decipher = OpenSSL::Cipher::AES.new(256, :OFB)
  decipher.decrypt
  decipher.key = key
  decipher.iv = iv
  res = decipher.update(encrypted_data) + decipher.final
  p res
end

# Authenticated Encryption mode
# GCM == (Galois/Counter Mode)
def aes256gcm
  cipher = OpenSSL::Cipher::AES.new(256, :GCM)

  # def random_key
  #   str = OpenSSL::Random.random_bytes(self.key_len)
  #   self.key = str
  # end
  puts "key length:"
  p cipher.key_len #=> 32
  key = cipher.random_key
  puts "key:"
  p key

  # === === encrypt === ===

  cipher.encrypt
  puts 'iv length'
  puts cipher.iv_len #=> 16
  iv = cipher.random_iv
  puts 'iv:'
  p iv
  auth_data = 'none'
  # https://ruby-doc.org/stdlib-2.4.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-auth_data-3D
  cipher.auth_data = auth_data
  encrypted_data = cipher.update('I love you') + cipher.final
  auth_tag = cipher.auth_tag
  p 'auth_tag:'
  p auth_tag
  p 'auth_tag bytesize:'
  p auth_tag.bytesize
  p 'encrypted_data:'
  p encrypted_data

  # === === decrypt === ===

  decipher = OpenSSL::Cipher::AES.new(256, :GCM)
  decipher.decrypt
  decipher.key = key
  decipher.iv = iv
  decipher.auth_tag = auth_tag
  decipher.auth_data = auth_data
  res = decipher.update(encrypted_data) + decipher.final
  p res
end

def aes256Ofb_with_cryppo
  puts 'Aes256Ofb cryppo way'
  key = Cryppo.generate_encryption_key('Aes256Ofb')
  encrypted_data = Cryppo.encrypt('Aes256Ofb', key, 'I love you')

  p encrypted_data.decrypt(key)
end

def aes256gcm_with_cryppo
  puts 'Aes256Gcm cryppo way'
  key = Cryppo.generate_encryption_key('Aes256Gcm')
  encrypted_data = Cryppo.encrypt('Aes256Gcm', key, 'I love you')

  p encrypted_data.decrypt(key)
end

def pbkdf2_encrypt_with_derived_key_with_cryppo
  encryption_strategy_name = 'Aes256Gcm'
  derivation_strategy_name = 'Pbkdf2Hmac'

  plain_data = "this is love"

  passphrase = 'my passphrase'
  key = passphrase

  encrypted_data_value = Cryppo.encrypt_with_derived_key(
    encryption_strategy_name,
    derivation_strategy_name,
    passphrase,
    plain_data
  )
  encrypted_data = encrypted_data_value.encrypted_data
  p encrypted_data

  decrypted_data = encrypted_data_value.decrypt(key)
  p decrypted_data
end

# 1. derive key
# 2. encrypt with it
# 3. derive again
# 4. decrypt with it
def pbkdf2_key_derivation_with_aes256gcm_openssl
  require 'securerandom'

  plain_data = "this is love"
  passphrase = 'my passphrase'

  key_length = 32
  min_iterations = 20000
  iteration_variance = 10
  variance = (min_iterations * (iteration_variance / 100.0)).to_i
  puts "min_iterations: #{min_iterations}"
  puts "variance: #{variance}"

  salt = OpenSSL::Random.random_bytes(20)

  # provide some randomisation to the number of iterations
  iterations = min_iterations + SecureRandom.random_number(variance)
  puts "iterations: #{iterations}"

  pdk = OpenSSL::KDF.pbkdf2_hmac(
    passphrase,
    salt: salt,
    iterations: iterations,
    length: key_length,
    hash: OpenSSL::Digest::SHA256.new
  )
  pdk_with_deriv_artefacts = {
    key: pdk,
    salt: salt,
    iter: iterations,
    length: key_length,
    hash: 'SHA256'
  }
  p pdk_with_deriv_artefacts

  ### encrypt with that key

  cipher = OpenSSL::Cipher::AES.new(256, :GCM)

  cipher.encrypt
  cipher.key = pdk
  iv = cipher.random_iv
  auth_data = 'none'
  cipher.auth_data = auth_data
  encrypted_data = cipher.update(plain_data) + cipher.final
  auth_tag = cipher.auth_tag
  p encrypted_data

  ### re-derive the key

  pdk2 = OpenSSL::KDF.pbkdf2_hmac(
    passphrase,
    salt: salt,
    iterations: iterations,
    length: key_length,
    hash: OpenSSL::Digest::SHA256.new
  )

  ### decrypt with that key

  decipher = OpenSSL::Cipher::AES.new(256, :GCM)
  decipher.decrypt
  decipher.key = pdk2
  decipher.iv = iv
  decipher.auth_tag = auth_tag
  decipher.auth_data = auth_data
  res = decipher.update(encrypted_data) + decipher.final
  p res
end

# openssl_ciphers
# rsa4096
# aes256Ofb
# aes256gcm
# aes256Ofb_with_cryppo
# aes256gcm_with_cryppo
# pbkdf2_encrypt_with_derived_key_with_cryppo
pbkdf2_key_derivation_with_aes256gcm_openssl
