defmodule Animal do

  def next_coordinates(state) do
    valid_neighbor_patches(state) 
      |> Enum.shuffle
      |> List.first
  end

  def valid_neighbor_patches(state) do
    board_size = state.board_size
    all_theoritical_neighboring_coordinates(state)
    |> Enum.filter(fn(coords) -> not_off_the_board(coords, board_size) end)
  end

  def all_theoritical_neighboring_coordinates(state) do
    %{x: x, y: y} = state.current_coordinates
    [
      %{x: x - 1, y: y - 1},
      %{x: x - 1, y: y},
      %{x: x - 1, y: y + 1},
      %{x: x, y: y - 1},
      %{x: x, y: y + 1},
      %{x: x + 1, y: y - 1},
      %{x: x + 1, y: y},
      %{x: x + 1, y: y + 1},
    ]
  end

  def not_off_the_board(%{x: x, y: _}, board_size) when x < 0, do: false
  def not_off_the_board(%{x: _, y: y}, board_size) when y < 0, do: false
  def not_off_the_board(%{x: x, y: _}, board_size) when x >= board_size, do: false
  def not_off_the_board(%{x: _, y: y}, board_size) when y >= board_size, do: false
  def not_off_the_board(%{x: _, y: _}, board_size), do: true
  
end