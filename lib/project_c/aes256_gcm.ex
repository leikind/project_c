defmodule ProjectC.Aes256Gcm do
  @moduledoc """
    Learning to use AES in Erlang
  """

  # in Ruby OpenSSL cipher.key_len returns 32 by default
  @key_length 32
  # OpenSSL::Cipher::AES.new(256, :GCM).iv_len return 12 in Ruby
  @iv_byte_size 12
  # like in Cryppo
  @auth_tag_length 16

  # like in Cryppo
  @additional_authenticated_data "none"

  def make_key, do: :crypto.strong_rand_bytes(@key_length)

  def binary_to_base64(bin) when is_binary(bin), do: Base.encode64(bin)

  def base64_to_binary(base64), do: Base.decode64(base64)

  def encrypt(data_to_encrypt, key) when is_binary(key) and is_binary(data_to_encrypt) do
    iv = :crypto.strong_rand_bytes(@iv_byte_size)

    # For encryption, set the EncryptFlag to true. For decryption, set it to false.
    {encrypted, auth_tag} =
      :crypto.crypto_one_time_aead(
        # Cipher
        :aes_256_gcm,
        # Key
        key,
        # IV
        iv,
        # InText
        data_to_encrypt,
        # AAD
        @additional_authenticated_data,
        # TagOrTagLength
        @auth_tag_length,
        true
      )

    {:ok, encrypted, iv, auth_tag}
  end

  def decrypt(encrypted, key, iv, auth_tag)
      when is_binary(key) and is_binary(encrypted) and is_binary(iv) and is_binary(auth_tag) do
    decrypted =
      :crypto.crypto_one_time_aead(
        # Cipher
        :aes_256_gcm,
        # Key
        key,
        # IV
        iv,
        # InText
        encrypted,
        # AAD
        @additional_authenticated_data,
        # TagOrTagLength
        auth_tag,
        false
      )

    {:ok, decrypted}
  end
end
