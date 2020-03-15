defmodule AesTest do
  use ExUnit.Case

  alias ProjectC.Aes

  test "with_erlang_crypto_legacy_api" do
    assert Aes.with_erlang_crypto_legacy_api("teen spirit") == "teen spirit"
  end

  test "with_erlang_crypto_new_api_aes_128_ctr" do
    assert Aes.with_erlang_crypto_new_api_aes_128_ctr("teen", " spirit") == "teen spirit"
  end

  test "with_erlang_crypto_new_api" do
    assert Aes.with_erlang_crypto_new_api("teen spirit, this is love, love, love") ==
             "teen spirit, this is love, love, love"
  end
end
