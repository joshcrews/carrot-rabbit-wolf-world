defmodule Wolf do
  import Animal

  use GenServer

  defstruct [:current_coordinates, :board_size, :rabbits_in_belly, :days_since_last_rabbits, :alive, :local_board]

  @move_tick_interval 500
  @rabbits_in_belly_before_reproduce 5
  @day_can_live_without_rabbits 50

  def start(state) do
    {:ok, pid} = GenServer.start_link(Wolf, state)
    :timer.send_interval(@move_tick_interval, pid, :move_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  # =============== Server Callbacks

  def init(%{current_coordinates: coordinates, board_size: board_size}) do
    local_board = empty_local_board
    {:ok, %Wolf{current_coordinates: coordinates, board_size: board_size, rabbits_in_belly: 0, days_since_last_rabbits: 0, alive: true, local_board: local_board}}
  end

  def handle_info(:move_tick, state) do
    new_state = tick_world(state)
    cond do
      new_state.alive ->
        {:noreply, new_state}
      :else ->
        CarrotWorldServer.remove_animal({self, :wolf}, new_state.current_coordinates)
        {:stop, :normal, new_state}
    end
  end

  def handle_call({:get, :coordinates}, _, state = %Wolf{current_coordinates: %{x: x, y: y}}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def handle_cast({:new_local_board, %{local_board: local_board}}, state) do
    new_state = %{state | local_board: local_board}
    {:noreply, new_state}
  end

  def terminate(:normal, state) do
    CarrotWorldServer.remove_animal({self, :wolf}, state.current_coordinates)
    :ok
  end

  def terminate(reason, state) do
    IO.inspect reason
    IO.inspect state
    :ok
  end
  
  # =============== Private functions

  def tick_world(state) do
    state
    |> move_patches
    |> try_to_eat_rabbits
    |> make_babies
    |> age
    |> die
  end

  def age(state) do
    %Wolf{state | days_since_last_rabbits: state.days_since_last_rabbits + 1}
  end

  def die(state) do
    cond do
      state.days_since_last_rabbits > @day_can_live_without_rabbits ->
        %Wolf{state | alive: false}
      :else ->
        state
    end
  end

  def make_babies(state) do
    cond do
     state.rabbits_in_belly > @rabbits_in_belly_before_reproduce ->
      starting_coordinates = state.current_coordinates
      Wolf.start(%{current_coordinates: starting_coordinates, board_size: state.board_size})
      %Wolf{state | rabbits_in_belly: 0}
    :else ->
      state
    end
  end

  def try_to_eat_rabbits(state) do
    {:ok, rabbits_found} = CarrotWorldServer.wolf_eat_rabbit(state.current_coordinates)
    cond do
      rabbits_found -> eat_rabbits(state)
      :else -> state
    end
  end

  def eat_rabbits(state) do
    %Wolf{state | rabbits_in_belly: state.rabbits_in_belly + 1, days_since_last_rabbits: 0}
  end

  def move_patches(state) do
    next_coordinates = next_coordinates(state)

    current_coordinates = state.current_coordinates

    enter_and_leave({current_coordinates, next_coordinates})
        
    %Wolf{state | current_coordinates: next_coordinates}
  end

  def enter_and_leave({old_coordinates, new_coordinates}) do
    CarrotWorldServer.move_animal({self, :wolf}, {old_coordinates, new_coordinates})
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

  def scored_possible_next_coordinates(state = %{board_size: board_size, local_board: local_board}) do
    all_theoritical_neighboring_coordinates(state)
    |> add_score
    |> decrease_score_for_off_the_board(board_size)
    |> increase_score_for_rabbits_nearby(local_board)
  end

  def increase_score_for_rabbits_nearby(coordinates_grid, local_board) do
    Enum.with_index(coordinates_grid)
    |>  Enum.map(fn({row, row_index}) ->
          Enum.with_index(row) |> Enum.map(fn({coordinates_map, column_index}) ->

            rabbits_nearby_count = rabbits_nearby_count(local_board, row_index, column_index)

            %{coordinates_map | score: coordinates_map.score + rabbits_nearby_count}
          end)
        end)
  end

  def rabbits_nearby_count(local_board, grid_row_index, grid_column_index) do
    # [0,0] = [1,1]
    # [1,1] = [3,3]
    # [2,2] = [5,5]

    row_index = 1 + (grid_row_index * 2)
    column_index = 1 + (grid_column_index * 2)

    micro_local_board(local_board, row_index, column_index)
    |> List.flatten
    |> Enum.filter(fn(x) -> x != nil end)
    |> Enum.count(fn({_, status}) -> (status == :rabbit) end)
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
        Enum.at(local_board, r) |> Enum.at(c) 
      end)
  end

  defp nine_squares(row_index, column_index) do
    [
      [
        {row_index - 1, column_index - 1},
        {row_index - 1, column_index},
        {row_index - 1, column_index + 1}
      ],
      [
        {row_index, column_index - 1},
        {row_index, column_index},
        {row_index, column_index + 1}
      ],
      [
        {row_index + 1, column_index - 1},
        {row_index + 1, column_index},
        {row_index + 1, column_index + 1}
      ]
    ]
  end

  def empty_local_board do
    [
      [[], [], [], [], [], [], []],
      [[], [], [], [], [], [], []],
      [[], [], [], [], [], [], []],
      [[], [], [], [], [], [], []],
      [[], [], [], [], [], [], []],
      [[], [], [], [], [], [], []],
      [[], [], [], [], [], [], []],
    ]
  end

end