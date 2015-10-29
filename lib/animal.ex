defmodule Animal do

  @local_board_size 9

  def move_patches(state) do
    next_coordinates = next_coordinates(state)

    current_coordinates = state.current_coordinates

    enter_and_leave(state.what_i_am, {current_coordinates, next_coordinates})
        
    %{state | current_coordinates: next_coordinates}
  end

  def enter_and_leave(animal_type, {old_coordinates, new_coordinates}) do
    CarrotWorldServer.move_animal({self, animal_type}, {old_coordinates, new_coordinates})
  end

  def next_coordinates(state) do
    scored_possible_next_coordinates(state)
    |> Enum.shuffle
    |> sort_by_score
    |> Enum.slice(0, 3)
    |> Enum.shuffle
    |> List.first
    |> Map.delete(:score)
  end

  def scored_possible_next_coordinates(state = %{board_size: board_size, local_board: local_board, what_i_eat: what_i_eat}) do
    all_theoritical_neighboring_coordinates(state)
    |> add_score
    |> decrease_score_for_off_the_board(board_size)
    |> increase_score_for_food_nearby(local_board, what_i_eat)
  end

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
        %{x: x - 1, y: y - 1, name: 'NW'},
        %{x: x - 1, y: y, name: 'W'},
        %{x: x - 1, y: y + 1, name: 'SW'},
      ],
      [
        %{x: x, y: y - 1, name: 'N'},
        %{x: x, y: y, name: 'C'},
        %{x: x, y: y + 1, name: 'S'},
      ],
      [
        %{x: x + 1, y: y - 1, name: 'NE'},
        %{x: x + 1, y: y, name: 'E'},
        %{x: x + 1, y: y + 1, name: 'SE'},
      ]
    ]
  end

  def on_board(%{x: x, y: _}, board_size) when x < 0, do: false
  def on_board(%{x: _, y: y}, board_size) when y < 0, do: false
  def on_board(%{x: x, y: _}, board_size) when x >= board_size, do: false
  def on_board(%{x: _, y: y}, board_size) when y >= board_size, do: false
  def on_board(%{x: _, y: _}, board_size), do: true

  def increase_score_for_food_nearby(coordinates_grid, local_board, what_i_eat) do
    Enum.with_index(coordinates_grid)
    |>  Enum.map(fn({row, row_index}) ->
          Enum.with_index(row) |> Enum.map(fn({coordinates_map, column_index}) ->

            food_count_nearby = food_count_nearby(local_board, row_index, column_index, what_i_eat)

            %{coordinates_map | score: coordinates_map.score + food_count_nearby}
          end)
        end)
  end

  def food_count_nearby(local_board, grid_row_index, grid_column_index, what_i_eat) do
    # [0,0] = [1,1]
    # [1,1] = [4,4]
    # [2,2] = [7,7]

    row_index = 1 + (grid_row_index * 3)
    column_index = 1 + (grid_column_index * 3)

    micro_local_board(local_board, row_index, column_index)
    |> List.flatten
    |> Enum.filter(fn(x) -> x != nil end)
    |> Enum.count(fn(status) -> (status == what_i_eat) end)
  end

  defp micro_local_board(local_board, row_index, column_index) do
    local_board_width = List.first(local_board) |> length
    local_board_height = length(local_board)

    nine_squares(row_index, column_index)
    |> Enum.map(fn(row) -> 
        Enum.filter(row, fn({r,c}) -> 
          ( r >= 0 && c >= 0 && r < local_board_height && c < local_board_width) 
        end) 
      end)
    |> List.flatten
    |> Enum.map(fn({r,c}) -> 
        Enum.at(local_board, c) |> Enum.at(r) 
      end)
  end

  defp nine_squares(row_index, column_index) do

    for i <- (row_index - 1..row_index + 1) do
      for j <- (column_index - 1..column_index + 1), do: {i,j}
    end
        
  end

  def empty_local_board do
    for i <- (1..@local_board_size) do
      for j <- (1..@local_board_size), do: []
    end
  end
  
end