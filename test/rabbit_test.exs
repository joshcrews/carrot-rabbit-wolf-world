require IEx

defmodule RabbitTest do
  use ExUnit.Case

  setup do
    board_size = 10
    CarrotWorldServer.start(%{board_size: board_size})
    {:ok, rabbit} = Rabbit.start(%{current_coordinates: %{x: 0, y: 0}, board_size: board_size})
    {:ok, [rabbit: rabbit]}
  end

  test "knows coordinates", context do
    assert Rabbit.coordinates(context[:rabbit]) == %{x: 0, y: 0}
  end

  test "moves patches", context do
    assert Rabbit.coordinates(context[:rabbit]) == %{x: 0, y: 0}
    send(context[:rabbit], :move_tick)
    assert Rabbit.coordinates(context[:rabbit]) != %{x: 0, y: 0}    
  end

  test "eats carrots" do
    rabbit = %Rabbit{carrots_in_belly: 0}
    assert Rabbit.eat_carrots(rabbit) == %Rabbit{carrots_in_belly: 1, days_since_last_carrots: 0}
  end

  test "makes babies" do
    rabbit = %Rabbit{carrots_in_belly: 6, current_coordinates: %{x: 0, y: 0}}
    assert Rabbit.make_babies(rabbit) == %Rabbit{carrots_in_belly: 0, current_coordinates: %{x: 0, y: 0}}
  end

  test "ages and dies" do
    rabbit = %Rabbit{days_since_last_carrots: 10, alive: true}
    new_rabbit = Rabbit.age(rabbit) |> Rabbit.die
    assert new_rabbit == %Rabbit{alive: false, days_since_last_carrots: 11}
  end

  test "prefers moving towards carrots" do
    local_board = [
      [[{1, :carrots}], [{1, :no_carrots}], [{1, :carrots}]],
      [[{1, :no_carrots}], [{1, :no_carrots}], [{1, :no_carrots}]],
      [[{1, :no_carrots}], [{1, :no_carrots}], [{1, :carrots}]]
    ]

    rabbit = %Rabbit{local_board: local_board, current_coordinates: %{x: 1, y: 1}}

    expected_result = [[%{score: 10, x: 0, y: 0}, %{score: 0, x: 0, y: 1}, %{score: 10, x: 0, y: 2}],
                       [%{score: 0, x: 1, y: 0}, %{score: 0, x: 1, y: 1}, %{score: 0, x: 1, y: 2}],
                       [%{score: 0, x: 2, y: 0}, %{score: 0, x: 2, y: 1}, %{score: 10, x: 2, y: 2}]]

   assert Rabbit.scored_possible_next_coordinates(rabbit) == expected_result
  end

end