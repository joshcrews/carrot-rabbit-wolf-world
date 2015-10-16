
require IEx
defmodule Rabbit do

  # use GenServer

  defstruct [:current_coordinates, :board_size, :carrots_in_belly]

  @move_tick_interval 500

  # Spawned onto a carrot patch
  #  -> eats any carrots there
  #    -> eating carrot patch resets patch to 0

  # Moves with each tick
  #  moves towards a random adjacent square with carrots
  #    -> cannot occupy a square that has an occupant (rabbit or future animal)
  #    -> eats those carrots
  #  or moves towards an random empty square


  # After eating 5 carrot patches
  #   -> second bunny appears in adjacent square


  # Dies after 50 rounds

  def start(starting_coordinates, board_size: board_size) do
    {:ok, pid} = GenServer.start_link(Rabbit, %{current_coordinates: starting_coordinates, board_size: board_size})
    :timer.send_interval(@move_tick_interval, pid, :move_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  # =============== Server Callbacks

  def init(%{current_coordinates: coordinates, board_size: board_size}) do
    CarrotWorldServer.move_rabbit(self, coordinates)
    {:ok, %Rabbit{current_coordinates: coordinates, board_size: board_size, carrots_in_belly: 0}}
  end

  def handle_info(:move_tick, state) do
    {:noreply, tick_world(state)}
  end

  def handle_call({:get, :coordinates}, _, state = %Rabbit{current_coordinates: %{x: x, y: y}}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def terminate(reason, state) do
    IO.puts "terminated Rabbit"
    IO.inspect reason
    IO.inspect state
    :ok
  end
  
  # =============== Private functions

  def tick_world(state) do
    state
    |> move_patches
    |> try_to_eat_carrots
  end

  def try_to_eat_carrots(state) do
    {:ok, carrots_found} = CarrotWorldServer.rabbit_eat_carrots(self, state.current_coordinates)
    cond do
      carrots_found -> eat_carrots(state)
      :else -> state
    end
  end

  def eat_carrots(state) do
    %Rabbit{state | carrots_in_belly: state.carrots_in_belly + 1}
  end

  def move_patches(state) do
    next_coordinates = next_coordinates(state)

    current_coordinates = state.current_coordinates

    enter_and_leave({current_coordinates, next_coordinates})
        
    %Rabbit{state | current_coordinates: next_coordinates}
  end

  def enter_and_leave({old_coordinates, new_coordinates}) do
    CarrotWorldServer.move_rabbit(self, {old_coordinates, new_coordinates})
  end

  def next_coordinates(state) do
    valid_neighbor_patches(state) 
      |> Enum.shuffle
      |> List.first
  end

  defp carrot_patch_finder do
    CarrotWorldServer
  end

  def valid_neighbor_patches(state) do
    board_size = state.board_size
    all_theoritical_neighboring_coordinates(state)
    |> Enum.filter(fn(coords) -> not_off_the_board(coords, board_size) end)
  end

  defp all_theoritical_neighboring_coordinates(state) do
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

  defp not_off_the_board(%{x: x, y: _}, board_size) when x < 0, do: false
  defp not_off_the_board(%{x: _, y: y}, board_size) when y < 0, do: false
  defp not_off_the_board(%{x: x, y: _}, board_size) when x >= board_size, do: false
  defp not_off_the_board(%{x: _, y: y}, board_size) when y >= board_size, do: false
  defp not_off_the_board(%{x: _, y: _}, board_size), do: true
  
  
end