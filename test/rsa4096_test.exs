defmodule Rsa4096Test do
  use ExUnit.Case

  alias ProjectC.Rsa4096

  test "rsa_encypt_decrypt_pure_erlang_crypto" do
    assert Rsa4096.rsa_encypt_decrypt_pure_erlang_crypto("is this love?") == "is this love?"
  end
end
