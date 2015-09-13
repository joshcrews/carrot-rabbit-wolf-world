defmodule CarrotPatch.GrowerTest do
  use ExUnit.Case

  test "carrots will grow" do
    carrot_patch = %CarrotPatch{has_carrots: false, carrot_growth_points: 0}
    assert carrot_patch.has_carrots == false

    new_carrot_patch = Enum.reduce((1..40), carrot_patch, fn(_, acc) -> 
      CarrotPatch.Grower.grow_and_recognize_new_carrots(acc) 
    end)

    assert new_carrot_patch.has_carrots == true
  end
  
end