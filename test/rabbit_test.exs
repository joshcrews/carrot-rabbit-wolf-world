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
    assert Rabbit.eat_carrots(rabbit) == %Rabbit{carrots_in_belly: 1}
  end

  test "makes babies" do
    rabbit = %Rabbit{carrots_in_belly: 6, current_coordinates: %{x: 0, y: 0}}
    assert Rabbit.make_babies(rabbit) == %Rabbit{carrots_in_belly: 0, current_coordinates: %{x: 0, y: 0}}
  end

end