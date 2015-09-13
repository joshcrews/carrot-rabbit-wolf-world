defmodule CarrotPatchTest do
  use ExUnit.Case
  
  setup do
    {:ok, carrot_patch} = CarrotPatch.start(%{x: 0, y: 0})
    {:ok, [carrot_patch: carrot_patch]}
  end

  test "grows carrots", context do
    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == false

    CarrotPatch.grow_carrots(context[:carrot_patch])

    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == true
  end

  test "removes carrots", context do
    CarrotPatch.grow_carrots(context[:carrot_patch])
    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == true

    CarrotPatch.remove_carrots(context[:carrot_patch])

    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == false
  end

  test "handles tick", context do
    CarrotPatch.grow_carrots(context[:carrot_patch])
    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == true

    CarrotPatch.remove_carrots(context[:carrot_patch])

    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == false
  end

  test "render graphics", context do
    assert CarrotPatch.to_screen(context[:carrot_patch]) == "0"

    CarrotPatch.grow_carrots(context[:carrot_patch])
    assert CarrotPatch.to_screen(context[:carrot_patch]) == "1"
  end

  test "knows coordinates" do
    {:ok, carrot_patch} = CarrotPatch.start(%{x: 1, y: 2})
    assert CarrotPatch.coordinates(carrot_patch) == %{x: 1, y: 2}
  end

  test "carrots will grow", context do
    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == false

    #
    # 100 growth ticks
    #
    (1..40) |> Enum.each(fn(_) -> send(context[:carrot_patch], :grow_tick) end)

    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == true
  end

  test "carrots will die", context do
    CarrotPatch.grow_carrots(context[:carrot_patch])
    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == true

    #
    # 40 growth ticks
    #
    (1..40) |> Enum.each(fn(_) -> send(context[:carrot_patch], :grow_tick) end)

    assert CarrotPatch.has_carrots?(context[:carrot_patch]) == false
  end

end