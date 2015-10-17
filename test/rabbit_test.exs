require IEx

defmodule RabbitTest do
  use ExUnit.Case

  setup do
    CarrotWorldServer.start(%{board_size: 10})
    {:ok, rabbit} = Rabbit.start(%{x: 0, y: 0}, board_size: 10)
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

end