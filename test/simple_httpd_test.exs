defmodule SimpleHttpdTest do
  use ExUnit.Case
  doctest SimpleHttpd

  test "greets the world" do
    assert SimpleHttpd.hello() == :world
  end
end
