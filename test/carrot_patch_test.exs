require IEx
defmodule CarrotPatchTest do
  use ExUnit.Case
  
  setup do
    CarrotWorldServer.start(%{board_size: 2})
    carrot_patch = %CarrotPatch{has_carrots: false, carrot_age: 0, x: 0, y: 0}
    {:ok, [carrot_patch: carrot_patch]}
  end

  test "knows coordinates" do
    {:ok, carrot_patch} = CarrotPatch.start(%{x: 0, y: 0, board_size: 2})
    assert CarrotPatch.coordinates(carrot_patch) == %{x: 0, y: 0}
  end

  test "carrots get eaten", context do
    carrot_patch = %{context[:carrot_patch] | has_carrots: true}
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