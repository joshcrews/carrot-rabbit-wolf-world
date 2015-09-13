defmodule RabbitTest do
  use ExUnit.Case

  setup do
    {:ok, carrot_patch} = CarrotPatch.start(%{x: 0, y: 0, board_size: 10})
    rabbit = CarrotPatch.spawn_rabbit(carrot_patch, 10)
    {:ok, [carrot_patch: carrot_patch, rabbit: rabbit]}
  end

  test "valid neighbor patches", context do
    rabbit_state = %{current_carrot_patch: context[:carrot_patch], board_size: 10}
    neighbor_patches = Rabbit.valid_neighbor_patches(rabbit_state)

    assert neighbor_patches == [%{x: 0, y: 1}, %{x: 1, y: 0}, %{x: 1, y: 1}]
  end

  # @tag :focus
  # test "moves around", context do
  #   rabbit_state = %{current_carrot_patch: context[:carrot_patch], board_size: 10}
  #   Rabbit.tick_world(rabbit_state)
  # end
end