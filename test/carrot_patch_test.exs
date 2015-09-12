defmodule CarrotPatchTest do
  use ExUnit.Case
  
  @tag :focus
  test "grows carrots" do
    {:ok, carrot_patch} = CarrotPatch.start

    assert CarrotPatch.has_carrots?(carrot_patch) == false

    CarrotPatch.grow_carrots(carrot_patch)

    assert CarrotPatch.has_carrots?(carrot_patch) == true
  end

  test "removes carrots" do
    {:ok, carrot_patch} = CarrotPatch.start

    CarrotPatch.grow_carrots(carrot_patch)
    assert CarrotPatch.has_carrots?(carrot_patch) == true

    CarrotPatch.remove_carrots(carrot_patch)

    assert CarrotPatch.has_carrots?(carrot_patch) == false
  end

  test "knows coordinates" do

  end

end