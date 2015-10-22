defmodule Animal do

  def add_score(coordinates_grid) do
    Enum.map(coordinates_grid, fn(row) ->
      Enum.map(row, fn(coordinates_map) ->
        Map.put(coordinates_map, :score, 0)
      end)
    end)
  end

  def sort_by_score(coordinates_grid) do
    List.flatten(coordinates_grid)
    |> Enum.sort(fn(coordinates_map1, coordinates_map2) -> coordinates_map1.score > coordinates_map2.score end)
  end

  def decrease_score_for_off_the_board(coordinates_grid, board_size) do
    Enum.map(coordinates_grid, fn(row) ->
      Enum.map(row, fn(coordinates_map) ->

        cond do
          on_board(coordinates_map, board_size) -> 
            coordinates_map
          :else ->
            score = coordinates_map.score
            %{coordinates_map | score: score - 100}
        end
            
      end)
    end)

  end

  def all_theoritical_neighboring_coordinates(%{current_coordinates: %{x: x, y: y}}) do
    [
      [
        %{x: x - 1, y: y - 1},
        %{x: x - 1, y: y},
        %{x: x - 1, y: y + 1},
      ],
      [
        %{x: x, y: y - 1},
        %{x: x, y: y},
        %{x: x, y: y + 1},
      ],
      [
        %{x: x + 1, y: y - 1},
        %{x: x + 1, y: y},
        %{x: x + 1, y: y + 1},
      ]
    ]
  end

  def on_board(%{x: x, y: _}, board_size) when x < 0, do: false
  def on_board(%{x: _, y: y}, board_size) when y < 0, do: false
  def on_board(%{x: x, y: _}, board_size) when x >= board_size, do: false
  def on_board(%{x: _, y: y}, board_size) when y >= board_size, do: false
  def on_board(%{x: _, y: _}, board_size), do: true
  
end