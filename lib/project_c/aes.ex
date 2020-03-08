defmodule ProjectC.Aes do
  @moduledoc """
    Learning to use AES in Erlang
  """

  # in Ruby OpenSSL cipher.key_len returns 32 by default
  @key_length 32
  # OpenSSL::Cipher::AES.new(256, :GCM).iv_len return 12 in Ruby
  @iv_byte_size 12
  # like in Cryppo
  @auth_tag_length 16

  def ciphers, do: :crypto.supports(:ciphers)

  #   [:chacha20, :blowfish_ecb, :blowfish_ofb64, :blowfish_cfb64, :blowfish_cbc,
  #  :des_ecb, :rc2_cbc, :aes_256_ecb, :aes_192_ecb, :aes_256_cfb128,
  #  :aes_192_cfb128, :aes_256_cfb8, :aes_192_cfb8, :aes_192_cbc, :des_ede3_cfb,
  #  :aes_256_cbc, :aes_128_ecb, :aes_128_cfb128, :aes_128_cfb8, :aes_128_cbc,
  #  :des_ede3_cbc, :aes_256_ccm, :aes_192_ccm, :aes_128_ccm, :chacha20_poly1305,
  #  :aes_256_gcm, :aes_192_gcm, :aes_128_gcm, :des_cfb, :des_cbc, :rc4,
  #  :aes_128_ctr, :aes_192_ctr, :aes_256_ctr, :aes_ige256]

  def with_apoc(clear_text) do
    key = Apoc.rand_bytes(@key_length)

    # Ruby cipher.iv_len #=> 16
    # @iv_byte_size is 16

    payload = Apoc.AES.encrypt(clear_text, key)

    {:ok, decrypted} = Apoc.AES.decrypt(payload, key)
    decrypted
  end

  def with_erlang_crypto_legacy_api(clear_text) do
    key = :crypto.strong_rand_bytes(@key_length)

    # IO.puts("key:")
    # key |> IO.inspect()
    # key |> byte_size() |> IO.puts()

    iv = :crypto.strong_rand_bytes(@iv_byte_size)

    # IO.puts("iv:")
    # iv |> IO.inspect()
    # iv |> byte_size() |> IO.puts()

    {encoded, tag} = :crypto.block_encrypt(:aes_gcm, key, iv, {"AES256GCM", clear_text})

    # IO.puts("tag:")
    # tag |> IO.inspect()
    # tag |> byte_size() |> IO.puts()

    # IO.puts("encoded:")
    # encoded |> IO.inspect()
    # encoded |> byte_size() |> IO.puts()

    :crypto.block_decrypt(:aes_gcm, key, iv, {"AES256GCM", encoded, tag}) |> IO.inspect()
  end

  def with_erlang_crypto_new_api_aes_128_ctr(clear_text1, clear_text2) do
    # key = :crypto.strong_rand_bytes(@key_length)
    key = :crypto.strong_rand_bytes(16)

    # iv = :crypto.strong_rand_bytes(@iv_byte_size)
    iv = :crypto.strong_rand_bytes(16)

    # For encryption, set the EncryptFlag to true. For decryption, set it to false.
    # state_enc = :crypto.crypto_init(:aes_256_gcm, key, iv, true)
    state_enc = :crypto.crypto_init(:aes_128_ctr, key, iv, true)

    chunk1 = :crypto.crypto_update(state_enc, clear_text1)
    chunk2 = :crypto.crypto_update(state_enc, clear_text2)

    state_dec = :crypto.crypto_init(:aes_128_ctr, key, iv, false)

    decoded1 = :crypto.crypto_update(state_dec, chunk1) |> IO.inspect()
    decoded2 = :crypto.crypto_update(state_dec, chunk2) |> IO.inspect()
    decoded1 <> decoded2
  end

  def with_erlang_crypto_new_api(clear_text) do
    key = :crypto.strong_rand_bytes(@key_length)
    iv = :crypto.strong_rand_bytes(@iv_byte_size)

    # like in Cryppo
    additional_authenticated_data = "none"

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
        clear_text,
        # AAD
        additional_authenticated_data,
        # TagOrTagLength
        @auth_tag_length,
        true
      )

    # encrypted |> IO.inspect()
    # auth_tag |> IO.inspect()

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
      additional_authenticated_data,
      # TagOrTagLength
      auth_tag,
      false
    )
  end
end
