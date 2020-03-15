defmodule Aes256GcmTest do
  use ExUnit.Case

  alias ProjectC.Aes256Gcm

  test "encrypt and decrypt" do
    key = Aes256Gcm.make_key()

    key |> Aes256Gcm.binary_to_base64() |> IO.inspect()

    {:ok, encrypted, iv, auth_tag} = "this is love..." |> Aes256Gcm.encrypt(key)

    encrypted |> Aes256Gcm.binary_to_base64() |> IO.inspect()

    {:ok, decrypted} = encrypted |> Aes256Gcm.decrypt(key, iv, auth_tag)

    assert decrypted == "this is love..."
  end

  test "compatibility_test: decode data encoded in Ruby" do
    # key = Aes256Gcm.make_key()

    # key |> Aes256Gcm.binary_to_base64() |> IO.inspect()

    # {:ok, encrypted, iv, auth_tag} = "this is love..." |> Aes256Gcm.encrypt(key)

    encrypted = "m66n41qXFsbXAX5A\n" |> Aes256Gcm.base64_to_binary()
    key = "29D3Dl2WWaGOagKUOnCDOf1Cc1GH37/+wfoMVWR0AAA=\n" |> Aes256Gcm.base64_to_binary()
    iv = "3E/XrwJ8M+u44bgf\n" |> Aes256Gcm.base64_to_binary()
    auth_tag = "2LFvZXTH9Gtaks+ykgdUfg==\n" |> Aes256Gcm.base64_to_binary()

    # encrypted |> Aes256Gcm.binary_to_base64() |> IO.inspect()

    {:ok, decrypted} = encrypted |> Aes256Gcm.decrypt(key, iv, auth_tag)

    assert decrypted == "this is love..."
  end

  test "compatibility_test: prepare data for Cryppo Ruby" do
    key = Aes256Gcm.make_key()

    {:ok, encrypted, iv, auth_tag} = "this is love..." |> Aes256Gcm.encrypt(key)

    {:ok, decrypted} = encrypted |> Aes256Gcm.decrypt(key, iv, auth_tag)

    assert decrypted == "this is love..."

    encrypted |> Aes256Gcm.binary_to_base64() |> IO.inspect()
    key |> Aes256Gcm.binary_to_base64() |> IO.inspect()
    iv |> Aes256Gcm.binary_to_base64() |> IO.inspect()
    auth_tag |> Aes256Gcm.binary_to_base64() |> IO.inspect()
  end
end
