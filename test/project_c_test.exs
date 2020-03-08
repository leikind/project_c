defmodule ProjectCTest do
  use ExUnit.Case

  alias ProjectC.Aes

  test "with_apoc" do
    assert Aes.with_apoc("this is love") == "this is love"
  end
end
