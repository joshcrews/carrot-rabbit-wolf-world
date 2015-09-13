defmodule CarrotPatch.KillerTest do
  use ExUnit.Case

  test "carrots will die" do
    carrot_patch = %CarrotPatch{has_carrots: true, carrot_age: 0}
    assert carrot_patch.has_carrots == true

    new_carrot_patch = Enum.reduce((1..40), carrot_patch, fn(_, acc) -> 
      CarrotPatch.Killer.age_existing_and_kill_carrots(acc) 
    end)

    assert new_carrot_patch.has_carrots == false
  end

end