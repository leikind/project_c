defmodule KeyDerivationTest do
  use ExUnit.Case

  alias ProjectC.Aes
  alias ProjectC.KeyDerivation

  test "pbkdf2_key_derivation_with_aes256gcm" do
    assert KeyDerivation.pbkdf2_key_derivation_with_aes256gcm(
             "this is love",
             "my passphrase"
           ) == "this is love"
  end
end
