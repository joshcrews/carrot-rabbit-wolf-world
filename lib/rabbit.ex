defmodule Rabbit do
  import Animal
  use GenServer

  defstruct [:current_coordinates, :board_size, :carrots_in_belly, :days_since_last_carrots, :alive, :local_board, :what_i_eat, :what_i_am, :what_i_flee]

  @move_tick_interval 300
  @carrots_in_belly_before_reproduce 3
  @day_can_live_without_carrots 15

  # Dies after 10 rounds with no carrots

  def start(state) do
    {:ok, pid} = GenServer.start_link(Rabbit, state)
    :timer.send_interval(@move_tick_interval, pid, :move_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  def eaten_by_wolf(pid) do
    send(pid, :eaten_by_wolf)
  end

  # =============== Server Callbacks

  def init(%{current_coordinates: coordinates, board_size: board_size}) do
    local_board = empty_local_board
    {:ok, %Rabbit{current_coordinates: coordinates, board_size: board_size, carrots_in_belly: 0, days_since_last_carrots: 0, alive: true, local_board: local_board, what_i_eat: :carrots, what_i_am: :rabbit, what_i_flee: :wolf}}
  end

  def handle_info(:move_tick, state) do
    new_state = tick_world(state)
    cond do
      new_state.alive ->
        {:noreply, new_state}
      :else ->
        CarrotWorldServer.remove_animal({self, :rabbit}, new_state.current_coordinates)
        {:stop, :normal, new_state}
    end
  end

  def handle_info(:eaten_by_wolf, state) do
    {:stop, :normal, state}
  end

  def handle_call({:get, :coordinates}, _, state = %Rabbit{current_coordinates: %{x: x, y: y}}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def handle_cast({:new_local_board, %{local_board: local_board}}, state) do
    new_state = %{state | local_board: local_board}
    {:noreply, new_state}
  end

  def terminate(:normal, _) do
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
    |> try_to_eat_carrots
    |> make_babies
    |> age
    |> die
  end

  def age(state) do
    %Rabbit{state | days_since_last_carrots: state.days_since_last_carrots + 1}
  end

  def die(state) do
    cond do
      state.days_since_last_carrots > @day_can_live_without_carrots ->
        %Rabbit{state | alive: false}
      :else ->
        state
    end
  end

  def make_babies(state) do
    cond do
     state.carrots_in_belly > @carrots_in_belly_before_reproduce ->
      Rabbit.start(%{current_coordinates: state.current_coordinates, board_size: state.board_size})
      %Rabbit{state | carrots_in_belly: 0}
    :else ->
      state
    end
  end

  def try_to_eat_carrots(state) do
    {:ok, carrots_found} = CarrotWorldServer.rabbit_eat_carrots(state.current_coordinates)
    cond do
      carrots_found -> eat_carrots(state)
      :else -> state
    end
  end

  def eat_carrots(state) do
    %Rabbit{state | carrots_in_belly: state.carrots_in_belly + 1, days_since_last_carrots: 0}
  end
  
end