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
  
end