require IEx
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


end