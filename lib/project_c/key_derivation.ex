defmodule ProjectC.KeyDerivation do
  @moduledoc """
    Pbkdf2
    https://github.com/basho/erlang-pbkdf2/blob/master/src/pbkdf2.erl
  """

  @key_length 32
  @salt_length 20

  # For aes_256_gcm:
  # OpenSSL::Cipher::AES.new(256, :GCM).iv_len return 12 in Ruby
  @iv_byte_size 12
  @auth_tag_length 16

  # in Cryppo these values are defaults that can be overridden
  @min_iterations 20_000
  @iteration_variance 10

  def pbkdf2_key_derivation_with_aes256gcm(plain_data, passphrase) do
    variance = (@min_iterations * (@iteration_variance / 100.0)) |> trunc

    "min_iterations: #{@min_iterations}" |> IO.puts()
    "variance: #{variance}" |> IO.puts()

    salt = :crypto.strong_rand_bytes(@salt_length)

    # provide some randomisation to the number of iterations
    # https://erlang.org/doc/man/crypto.html#rand_seed-0
    # should only call once?
    :crypto.rand_seed()
    iterations = @min_iterations + :rand.uniform(variance)
    "iterations: #{iterations}" |> IO.puts()

    {:ok, pdk} =
      :pbkdf2.pbkdf2(
        {:hmac, :sha256},
        passphrase,
        salt,
        iterations,
        @key_length
      )

    pdk_with_deriv_artefacts = %{
      key: pdk,
      salt: salt,
      iter: iterations,
      length: @key_length,
      hash: :sha256
    }

    pdk_with_deriv_artefacts |> IO.inspect()

    ### encrypt with that key

    iv = :crypto.strong_rand_bytes(@iv_byte_size)

    # like in Cryppo
    additional_authenticated_data = "none"

    # For encryption, set the EncryptFlag to true. For decryption, set it to false.
    {encrypted, auth_tag} =
      :crypto.crypto_one_time_aead(
        # Cipher
        :aes_256_gcm,
        # Key
        pdk,
        # IV
        iv,
        # InText
        plain_data,
        # AAD
        additional_authenticated_data,
        # TagOrTagLength
        @auth_tag_length,
        true
      )

    # encrypted |> IO.inspect()
    # auth_tag |> IO.inspect()

    ### re-derive the key

    {:ok, pdk2} =
      :pbkdf2.pbkdf2(
        {:hmac, :sha256},
        passphrase,
        salt,
        iterations,
        @key_length
      )

    ### decrypt with that key

    :crypto.crypto_one_time_aead(
      # Cipher
      :aes_256_gcm,
      # Key
      pdk2,
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
