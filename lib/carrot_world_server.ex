require IEx

defmodule CarrotWorldServer do
  use GenServer

  @world_tick 100
  @rabbit_spawn_tick 2000
  @wolf_spawn_tick 4000

  def start(%{board_size: board_size}) do
    GenServer.start_link(CarrotWorldServer, {:board_size, board_size}, name: :carrot_world_server)
    {:ok, :carrot_world_server}
  end

  def start_in_production do
    start(%{board_size: 30})
  end

  def sip do
    {:ok, :carrot_world_server} = start_in_production
    :timer.send_interval(@world_tick, :carrot_world_server, :world_tick)
    :timer.send_interval(@rabbit_spawn_tick, :carrot_world_server, :rabbit_spawn_tick)
    :timer.send_interval(@wolf_spawn_tick, :carrot_world_server, :wolf_spawn_tick)
  end
  

  def render_map do
    GenServer.call(:carrot_world_server, {:get, :map})
  end

  def put_patch(%{x: x, y: y, graphics: graphics}) do
    GenServer.cast(:carrot_world_server, {:put_patch, %{x: x, y: y, graphics: graphics}})
  end

  def carrot_patch_at(%{x: x, y: y}) do
    GenServer.call(:carrot_world_server, {:get_patch_at, %{x: x, y: y}})
  end

  def move_animal(animal, {old_coordinates, new_coordinates}) do
    move_animal(animal, new_coordinates)
    remove_animal(animal, old_coordinates)
  end

  def move_animal(animal, coordinates) do
    patch = carrot_patch_at(coordinates)
    CarrotPatch.occupant_arrived({patch, animal})
  end  

  def remove_animal(animal, coordinates) do
    patch = carrot_patch_at(coordinates)
    CarrotPatch.occupant_left({patch, animal})
  end  

  def rabbit_eat_carrots(rabbit, coordinates) do
    patch_to_eat = carrot_patch_at(coordinates)
    {:ok, got_some_carrots} = CarrotPatch.eat_carrots(patch_to_eat)
  end

  def wolf_eat_rabbits(wolf, coordinates) do
    patch = carrot_patch_at(coordinates)
    {:ok, got_some_rabbits} = CarrotPatch.eat_rabbits(patch)
  end
  
  
  # ===============

  def init({:board_size, board_size}) do
    state = CarrotWorld.build_initial_world({:board_size, board_size})
    {:ok, state}
  end

  def handle_call({:get, :map}, _, state = %{board: board}) do
    {:reply, board, state}
  end

  def handle_call({:get_patch_at, %{x: x, y: y}}, _, state = %{carrot_patches: carrot_patches}) do
    carrot_patch = CarrotWorld.find_at(carrot_patches, %{x: x, y: y})
    {:reply, carrot_patch, state}
  end

  def handle_cast({:put_patch, %{x: x, y: y, graphics: graphics}}, state = %{board: board}) do
    new_board = CarrotWorld.replace_at(board, %{x: x, y: y}, graphics)
    new_state = %CarrotWorld{state | board: new_board}
    {:noreply, new_state}
  end

  def handle_info(:world_tick, state = %{board: board}) do
    board
    |> Enum.each(fn(row) -> IO.puts(Enum.join(row, " ")) end)

    IO.puts ""
    IO.puts ""
    {:noreply, state}
  end

  def handle_info(:rabbit_spawn_tick, state = %{board: board}) do
    board_size = length(board)
    spawn_rabbit(board_size)
    {:noreply, state}
  end  

  def handle_info(:wolf_spawn_tick, state = %{board: board}) do
    board_size = length(board)
    spawn_wolf(board_size)
    {:noreply, state}
  end

  def spawn_rabbit(board_size) do
    x = [0,board_size - 1] |> Enum.shuffle |> List.first
    y = (0 .. board_size - 1) |> Enum.to_list |> Enum.shuffle |> List.first
    
    coordinates = %{x: x, y: y}

    Rabbit.start(coordinates, board_size: board_size)
  end

  def spawn_wolf(board_size) do
    y = [0,board_size - 1] |> Enum.shuffle |> List.first
    x = (0 .. board_size - 1) |> Enum.to_list |> Enum.shuffle |> List.first
    
    coordinates = %{x: x, y: y}

    Wolf.start(coordinates, board_size: board_size)
  end

  
end
