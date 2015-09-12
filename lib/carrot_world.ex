require IEx
defmodule CarrotWorld do
  @timeout 60000
  import Enum, only: [at: 2, count: 1]

  def build_initial_world({:board_size, board_size}) do
    board_size_less_one = board_size - 1
    Enum.to_list(0..board_size_less_one)
    |> Enum.map(fn(x) -> 
      Enum.to_list(0..board_size_less_one) |> Enum.map(fn(y) -> 
        {:ok, carrot_patch} = CarrotPatch.start(%{x: x, y: y}) 
        CarrotPatch.to_screen(carrot_patch)
      end)
    end)
  end

  def replace_at(grid, %{x: x, y: y}, contents) do
    new_row = Enum.at(grid, x)
    |> List.replace_at(y, contents)

    List.replace_at(grid, x, new_row)
  end
  
  
end