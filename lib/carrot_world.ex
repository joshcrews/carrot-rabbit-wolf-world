require IEx
defmodule CarrotWorld do
  @timeout 60000
  defstruct [:board, :carrot_patches]
  import Enum, only: [at: 2, count: 1]

  def build_initial_world({:board_size, board_size}) do
    carrot_patches = spawn_carrot_patches({:board_size, board_size})
    board = carrot_patches
    |> Enum.map(fn(row) -> Enum.map(row, fn(_) -> " " end) end)

    %CarrotWorld{board: board, carrot_patches: carrot_patches}
  end

  def replace_at(grid, %{x: x, y: y}, contents) do
    new_row = Enum.at(grid, x)
    |> List.replace_at(y, contents)

    List.replace_at(grid, x, new_row)
  end

  def find_at(grid, %{x: x, y: y}) do
    Enum.at(grid, x) |> Enum.at(y)
  end
  

  # ========= Private Functions

  def spawn_carrot_patches({:board_size, board_size}) do
    board_size_less_one = board_size - 1
    Enum.to_list(0..board_size_less_one)
    |> Enum.map(fn(x) -> 
      Enum.to_list(0..board_size_less_one) |> Enum.map(fn(y) -> 
        {:ok, carrot_patch} = CarrotPatch.start(%{x: x, y: y, board_size: board_size}) 
        carrot_patch
      end)
    end)
  end
  
  
end