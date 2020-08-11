defmodule ClockifyBotTest do
  use ExUnit.Case
  doctest ClockifyBot

  test "greets the world" do
    assert ClockifyBot.hello() == :world
  end
end
