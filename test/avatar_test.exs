defmodule AvatarTest do
  use ExUnit.Case
  doctest Avatar

  test "it generate a avatar" do
    filename = Avatar.generate "ksz2k", 200
    assert File.exists?(filename)
  end
end
