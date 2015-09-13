defmodule CarrotWorldTest do
  use ExUnit.Case
  
  test "replace_at" do
    start_grid = [
      ["0","0","0"],
      ["0","0","0"],
      ["0","0","0"],
    ]
    new_grid = CarrotWorld.replace_at(start_grid, %{x: 2, y: 2}, "1")

    correct_grid = [
      ["0","0","0"],
      ["0","0","0"],
      ["0","0","1"],
    ]

    assert new_grid == correct_grid
  end

  test "find_at" do
    carrot_patch = 15
    carrot_patches = [[carrot_patch, 0], [0, 0]]
    coordinates = %{x: 0, y: 0}
    found_carrot_patch = CarrotWorld.find_at(carrot_patches, coordinates)

    assert found_carrot_patch == carrot_patch
  end
  
end