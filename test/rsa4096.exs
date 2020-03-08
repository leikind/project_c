defmodule Rsa4096Test do
  use ExUnit.Case

  alias ProjectC.Rsa4096

  test "rsa_encypt_decrypt_with_ex_public_key" do
    assert Rsa4096.rsa_encypt_decrypt_with_ex_public_key("this is love!!!") == "this is love!!!"
  end

  test "rsa_encypt_decrypt_pure_erlang_crypto" do
    assert Rsa4096.rsa_encypt_decrypt_pure_erlang_crypto("is this love?") == "is this love?"
    # assert ProjectC.apoc() == {:ok, "this is love"}
    # assert ProjectC.hello() == :world
    # assert ProjectC.rsa_encypt_decrypt_with_ex_public_key() == "this is love"
  end

  # test "bar" do
  #   ProjectC.rsa_encypt_decrypt_pure_erlang_crypto()
  #   # assert ProjectC.apoc() == {:ok, "this is love"}
  #   # assert ProjectC.hello() == :world
  #   # assert ProjectC.rsa_encypt_decrypt_with_ex_public_key() == "this is love"
  # end
end
