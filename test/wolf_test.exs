require IEx

defmodule WolfTest do
  use ExUnit.Case

  setup do
    CarrotWorldServer.start(%{board_size: 10})
    {:ok, wolf} = Wolf.start(%{x: 0, y: 0}, board_size: 10)
    {:ok, [wolf: wolf]}
  end

  test "knows coordinates", context do
    assert Wolf.coordinates(context[:wolf]) == %{x: 0, y: 0}
  end

  test "moves patches", context do
    assert Wolf.coordinates(context[:wolf]) == %{x: 0, y: 0}
    send(context[:wolf], :move_tick)
    assert Wolf.coordinates(context[:wolf]) != %{x: 0, y: 0}    
  end

  test "eats rabbits" do
    wolf = %Wolf{rabbits_in_belly: 0}
    assert Wolf.eat_rabbits(wolf) == %Wolf{rabbits_in_belly: 1, days_since_last_rabbits: 0}
  end

  test "makes babies" do
    wolf = %Wolf{rabbits_in_belly: 6, current_coordinates: %{x: 0, y: 0}}
    assert Wolf.make_babies(wolf) == %Wolf{rabbits_in_belly: 0, current_coordinates: %{x: 0, y: 0}}
  end

  test "ages and dies" do
    wolf = %Wolf{days_since_last_rabbits: 50, alive: true}
    new_wolf = Wolf.age(wolf) |> Wolf.die
    assert new_wolf == %Wolf{alive: false, days_since_last_rabbits: 51}
  end

end