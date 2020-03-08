defmodule ProjectC.Aes do
  @moduledoc """
    Learning to use AES in Erlang
  """

  def ciphers, do: :crypto.supports(:ciphers)

  #   [:chacha20, :blowfish_ecb, :blowfish_ofb64, :blowfish_cfb64, :blowfish_cbc,
  #  :des_ecb, :rc2_cbc, :aes_256_ecb, :aes_192_ecb, :aes_256_cfb128,
  #  :aes_192_cfb128, :aes_256_cfb8, :aes_192_cfb8, :aes_192_cbc, :des_ede3_cfb,
  #  :aes_256_cbc, :aes_128_ecb, :aes_128_cfb128, :aes_128_cfb8, :aes_128_cbc,
  #  :des_ede3_cbc, :aes_256_ccm, :aes_192_ccm, :aes_128_ccm, :chacha20_poly1305,
  #  :aes_256_gcm, :aes_192_gcm, :aes_128_gcm, :des_cfb, :des_cbc, :rc4,
  #  :aes_128_ctr, :aes_192_ctr, :aes_256_ctr, :aes_ige256]

  def with_apoc(clear_text) do
    # in Ruby OpenSSL cipher.key_len returns 32 by default
    key = Apoc.rand_bytes(32)

    # Ruby cipher.iv_len #=> 16
    # @iv_byte_size is 16

    payload = Apoc.AES.encrypt(clear_text, key)

    {:ok, decrypted} = Apoc.AES.decrypt(payload, key)
    decrypted
  end
end
