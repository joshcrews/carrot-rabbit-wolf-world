defmodule Rabbit do

  defstruct [:current_carrot_patch, :board_size]

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

  def start(starting_carrot_patch, board_size) do
    {:ok, pid} = GenServer.start_link(Rabbit, %{current_carrot_patch: starting_carrot_patch, board_size: board_size})
    :timer.send_interval(@move_tick_interval, pid, :move_tick)
    {:ok, pid}
  end

  # =============== Server Callbacks

  def init(%{current_carrot_patch: carrot_patch, board_size: board_size}) do
    CarrotPatch.register_occupant({carrot_patch, self})
    {:ok, %Rabbit{current_carrot_patch: carrot_patch, board_size: board_size}}
  end

  def handle_info(:move_tick, state) do
    {:noreply, tick_world(state)}
  end
  
  # =============== Private functions

  def tick_world(state) do
    state
    |> move_patches
  end

  defp move_patches(state) do
    next_carrot_patch = next_carrot_patch_coordinates(state)
                          |> carrot_patch_finder.carrot_patch_at

    CarrotPatch.occupant_arrived({next_carrot_patch, self})
    CarrotPatch.occupant_left({state.current_carrot_patch, self})
        
    %Rabbit{state | current_carrot_patch: next_carrot_patch}
  end

  def next_carrot_patch_coordinates(state) do
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
    %{x: x, y: y} = CarrotPatch.coordinates(state.current_carrot_patch)
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