defmodule NervesCogTest do
  use ExUnit.Case
  doctest NervesCog

  test "greets the world" do
    assert NervesCog.hello() == :world
  end
end
