defmodule CarrotPatchTest do
  use ExUnit.Case
  
  setup do
    {:ok, carrot_patch} = CarrotPatch.start(%{x: 0, y: 0, board_size: 10})
    {:ok, [carrot_patch: carrot_patch]}
  end

  test "render graphics", context do
    empty = %{has_carrots: false, occupant: nil}
    assert CarrotPatch.to_screen(empty) == " "

    carrots = %{has_carrots: true, occupant: nil}
    assert CarrotPatch.to_screen(carrots) == "1"

    {:ok, rabbit_pid} = CarrotPatch.spawn_rabbit(context[:carrot_patch], 10)
    rabbits = %{has_carrots: true, occupant: rabbit_pid}
    assert CarrotPatch.to_screen(rabbits) == "2"
  end

  test "knows coordinates", context do
    assert CarrotPatch.coordinates(context[:carrot_patch]) == %{x: 0, y: 0}
  end

end