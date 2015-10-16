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
    assert CarrotPatch.to_screen(carrots) == "."

    rabbits = %{has_carrots: true, occupant: 1}
    assert CarrotPatch.to_screen(rabbits) == "R"
  end

  test "knows coordinates", context do
    assert CarrotPatch.coordinates(context[:carrot_patch]) == %{x: 0, y: 0}
  end

  test "spawns rabbit", context do
    CarrotWorldServer.start(%{board_size: 10})
    coordinates = CarrotPatch.coordinates(context[:carrot_patch])
    {:ok, rabbit} = CarrotPatch.spawn_rabbit(coordinates, 10)
    assert Rabbit.coordinates(rabbit) == %{x: 0, y: 0}
  end


end