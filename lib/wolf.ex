defmodule Wolf do
  import Animal

  # use GenServer

  defstruct [:current_coordinates, :board_size, :rabbits_in_belly, :days_since_last_rabbits, :alive]

  @move_tick_interval 500
  @rabbits_in_belly_before_reproduce 5
  @day_can_live_without_rabbits 50

  def start(starting_coordinates, board_size: board_size) do
    {:ok, pid} = GenServer.start_link(Wolf, %{current_coordinates: starting_coordinates, board_size: board_size})
    :timer.send_interval(@move_tick_interval, pid, :move_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  # =============== Server Callbacks

  def init(%{current_coordinates: coordinates, board_size: board_size}) do
    {:ok, %Wolf{current_coordinates: coordinates, board_size: board_size, rabbits_in_belly: 0, days_since_last_rabbits: 0, alive: true}}
  end

  def handle_info(:move_tick, state) do
    new_state = tick_world(state)
    cond do
      new_state.alive ->
        {:noreply, new_state}
      :else ->
        {:stop, :normal, new_state}
    end
  end

  def handle_call({:get, :coordinates}, _, state = %Wolf{current_coordinates: %{x: x, y: y}}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def terminate(:normal, state) do
    CarrotWorldServer.remove_animal({self, :wolf}, state.current_coordinates)
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
      Wolf.start(starting_coordinates, board_size: state.board_size)
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

  def best_three_next_moves(coordinates_list) do
    Enum.slice(coordinates_list, 0, 3)
  end

end