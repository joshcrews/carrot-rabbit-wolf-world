require IEx

defmodule WolfTest do
  use ExUnit.Case

  setup do
    board_size = 10
    CarrotWorldServer.start(%{board_size: board_size})
    {:ok, wolf} = Wolf.start(%{current_coordinates: %{x: 0, y: 0}, board_size: board_size})
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

  test "prefers moving towards nearby rabbits" do
    local_board = [
      [[:rabbit, :rabbit], [], [], [], [], [], [], [], []],
      [[:rabbit], [], [], [], [], [], [], [], []],
      [[:rabbit], [], [], [], [], [], [], [], []],
      [[:rabbit], [], [], [], [], [], [], [], []],
      [[:rabbit], [], [], [], [], [], [], [], []],
      [[:rabbit], [], [], [], [], [], [], [], []],
      [[:rabbit], [], [], [], [], [], [:rabbit], [], []],
      [[:rabbit], [], [], [], [], [], [:rabbit], [], []],
      [[:rabbit], [], [], [], [], [], [:rabbit], [], []],
    ]

    wolf = %Wolf{local_board: local_board, current_coordinates: %{x: 3, y: 3}, what_i_eat: :rabbit}

    expected_result = [[%{name: 'NW', score: 4, x: 2, y: 2}, %{name: 'W', score: 3, x: 2, y: 3}, %{name: 'SW', score: 3, x: 2, y: 4}],
                        [%{name: 'N', score: 0, x: 3, y: 2}, %{name: 'C', score: 0, x: 3, y: 3}, %{name: 'S', score: 0, x: 3, y: 4}],
                        [%{name: 'NE', score: 0, x: 4, y: 2}, %{name: 'E', score: 0, x: 4, y: 3}, %{name: 'SE', score: 3, x: 4, y: 4}]]

   assert expected_result == Animal.scored_possible_next_coordinates(wolf)
  end

end