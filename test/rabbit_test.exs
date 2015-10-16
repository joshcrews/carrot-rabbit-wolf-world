require IEx

defmodule RabbitTest do
  use ExUnit.Case

  setup do
    CarrotWorldServer.start(%{board_size: 10})
    {:ok, rabbit} = Rabbit.start(%{x: 0, y: 0}, 10)
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

  # test "valid neighbor patches", context do
  #   rabbit_state = %{current_carrot_patch: context[:carrot_patch], board_size: 10}
  #   neighbor_patches = Rabbit.valid_neighbor_patches(rabbit_state)

  #   assert neighbor_patches == [%{x: 0, y: 1}, %{x: 1, y: 0}, %{x: 1, y: 1}]
  # end

  # @tag :focus
  # test "moves around", context do
  #   rabbit_state = %{current_carrot_patch: context[:carrot_patch], board_size: 10}
  #   Rabbit.tick_world(rabbit_state)
  # end
end