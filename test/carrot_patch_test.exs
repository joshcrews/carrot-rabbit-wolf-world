require IEx
defmodule CarrotPatchTest do
  use ExUnit.Case
  
  setup do
    {:ok, carrot_patch} = CarrotPatch.start(%{x: 0, y: 0, board_size: 10})
    {:ok, [carrot_patch: carrot_patch]}
  end

  test "render graphics", context do
    empty = %{has_carrots: false, occupants: []}
    assert CarrotPatch.to_screen(empty) == " "

    carrots = %{has_carrots: true, occupants: []}
    assert CarrotPatch.to_screen(carrots) == "."

    rabbit = {1, :rabbit}
    rabbits = %{has_carrots: true, occupants: [rabbit]}
    assert CarrotPatch.to_screen(rabbits) == "R"

    wolf = {1, :wolf}
    wolves = %{has_carrots: true, occupants: [wolf]}
    assert CarrotPatch.to_screen(wolves) == "W"
  end

  test "knows coordinates", context do
    assert CarrotPatch.coordinates(context[:carrot_patch]) == %{x: 0, y: 0}
  end

  test "carrots get eaten" do
    carrot_patch = %CarrotPatch{has_carrots: true, carrot_age: 0}
    assert carrot_patch.has_carrots == true

    {reply, new_state} = CarrotPatch.do_eat_carrots(carrot_patch)

    assert new_state.has_carrots == false
    assert reply == true
  end

  test "carrots dont get eaten" do
    carrot_patch = %CarrotPatch{has_carrots: false, carrot_age: 0}
    assert carrot_patch.has_carrots == false

    {reply, new_state} = CarrotPatch.do_eat_carrots(carrot_patch)

    assert new_state.has_carrots == false
    assert reply == false
  end

  test "wolf eats a rabbit" do
    CarrotWorldServer.start(%{board_size: 1})

    {:ok, rabbit} = Rabbit.start(%{x: 0, y: 0}, board_size: 1)
    rabbit_tuple = {rabbit, :rabbit}

    rabbits = [rabbit_tuple]

    carrot_patch = %CarrotPatch{occupants: rabbits}

    {reply, new_state} = CarrotPatch.do_eat_rabbits(carrot_patch)

    assert reply == true
    assert new_state.occupants == []
  end


end