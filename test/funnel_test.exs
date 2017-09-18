defmodule FunnelTest do
  use ExUnit.Case
  doctest Funnel

  test "greets the world" do
    assert Funnel.hello() == :world
  end
end
