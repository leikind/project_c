defmodule ProjectC.Rsa4096 do
  @moduledoc """
    Learning to use RSA in Erlang
  """

  # size is an integer representing the desired key size.
  # Keys smaller than 1024 should be considered insecure.
  # exponent is an odd number normally 3, 17, or 65537.
  # 65537 is the default in OpenSSL, and hence in ruby Cryppo
  # 4096 is the key size in Cryppo
  @size 4_096
  @exponent 65_537

  # rsa_padding() =
  #   rsa_pkcs1_padding | rsa_pkcs1_oaep_padding |
  #   rsa_sslv23_padding | rsa_x931_padding | rsa_no_padding
  # rsa_pkcs1_oaep_padding is the padding in Cryppo
  @padding :rsa_pkcs1_oaep_padding

  defp make_rsa_key do
    private_key_erlang_tuple = :public_key.generate_key({:rsa, @size, @exponent})

    private_key_as_map = %{
      version: elem(private_key_erlang_tuple, 1),
      public_modulus: elem(private_key_erlang_tuple, 2),
      public_exponent: elem(private_key_erlang_tuple, 3),
      private_exponent: elem(private_key_erlang_tuple, 4),
      prime_one: elem(private_key_erlang_tuple, 5),
      prime_two: elem(private_key_erlang_tuple, 6),
      exponent_one: elem(private_key_erlang_tuple, 7),
      exponent_two: elem(private_key_erlang_tuple, 8),
      ctr_coefficient: elem(private_key_erlang_tuple, 9),
      other_prime_infos: elem(private_key_erlang_tuple, 10)
    }

    public_key =
      {:RSAPublicKey, private_key_as_map.public_modulus, private_key_as_map.public_exponent}

    {private_key_erlang_tuple, public_key}
  end

  defp encrypt(clear_text, {:RSAPublicKey, _, _} = public_key) do
    :public_key.encrypt_public(clear_text, public_key, rsa_padding: @padding)
  end

  defp decrypt(encrypted_bytes, private_key_erlang_tuple)
       when is_binary(encrypted_bytes) and is_tuple(private_key_erlang_tuple) and
              elem(private_key_erlang_tuple, 0) == :RSAPrivateKey do
    :public_key.decrypt_private(encrypted_bytes, private_key_erlang_tuple, rsa_padding: @padding)
  end

  defp to_pem(private_key_erlang_tuple)
       when is_tuple(private_key_erlang_tuple) and
              elem(private_key_erlang_tuple, 0) == :RSAPrivateKey do
    pem_entry = :public_key.pem_entry_encode(:RSAPrivateKey, private_key_erlang_tuple)
    :public_key.pem_encode([pem_entry])
  end

  defp from_pem(pem) when is_binary(pem) do
    [pem_entry] = :public_key.pem_decode(pem)
    :public_key.pem_entry_decode(pem_entry)
  end

  def rsa_encypt_decrypt_pure_erlang_crypto(clear_text) do
    {private_key_erlang_tuple, public_key} = make_rsa_key()

    encrypted_bytes = encrypt(clear_text, public_key)

    pem = to_pem(private_key_erlang_tuple)

    private_key_erlang_tuple_restored = from_pem(pem)

    decrypt(encrypted_bytes, private_key_erlang_tuple_restored)
  end
end
