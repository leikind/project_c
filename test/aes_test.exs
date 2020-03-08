defmodule AesTest do
  use ExUnit.Case

  alias ProjectC.Aes

  test "with_apoc" do
    assert Aes.with_apoc("this is love") == "this is love"
  end

  test "with_erlang_crypto_legacy_way" do
    # assert Aes.with_apoc("this is love") == "this is love"
    assert Aes.with_erlang_crypto_legacy_way("teen spirit") == "teen spirit"
  end
end
