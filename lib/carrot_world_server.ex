require IEx

defmodule CarrotWorldServer do
  use GenServer

  @world_tick 100

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
  end
  
  def put_patch(%{x: x, y: y, status: status}) do
    GenServer.cast(:carrot_world_server, {:put_patch, %{x: x, y: y, status: status}})
  end

  def move_animal(animal, {old_coordinates, new_coordinates}) do
    move_animal(animal, new_coordinates)
    remove_animal(animal, old_coordinates)
  end

  def move_animal(animal, coordinates) do
    GenServer.cast(:carrot_world_server, {:move_animal, animal, coordinates})
  end  

  def remove_animal(animal, coordinates) do
    GenServer.cast(:carrot_world_server, {:remove_animal, animal, coordinates})
  end  

  def rabbit_eat_carrots(coordinates) do
    patch_to_eat = GenServer.call(:carrot_world_server, {:get_patch_at, coordinates})
    CarrotPatch.eat_carrots(patch_to_eat)
  end

  def wolf_eat_rabbit(coordinates) do
    GenServer.call(:carrot_world_server, {:wolf_eat_rabbit, coordinates})
  end
  
  
  # ===============

  def init({:board_size, board_size}) do
    state = CarrotWorld.build_initial_world({:board_size, board_size})
    spawn_wolf(board_size)
    spawn_rabbit(board_size)
    {:ok, state}
  end

  def handle_call({:get_patch_at, coordinates}, _, state = %{board: board}) do
    carrot_patch = CarrotWorld.get_patch_at(board, coordinates)
    {:reply, carrot_patch, state}
  end

  def handle_call({:wolf_eat_rabbit, coordinates}, _, state = %{board: board}) do
    {reply, board} = CarrotWorld.wolf_eat_rabbit(board, coordinates)
    state = %{state | board: board}
    {:reply, reply, state}
  end

  def handle_cast({:put_patch, %{x: x, y: y, status: status}}, state = %{board: board}) do
    new_board = CarrotWorld.replace_at(board, %{x: x, y: y}, status)
    new_state = %CarrotWorld{state | board: new_board}
    {:noreply, new_state}
  end

  def handle_cast({:move_animal, animal, coordinates}, state = %{board: board}) do
    new_board = CarrotWorld.move_animal(board, animal, coordinates)
    new_state = %CarrotWorld{state | board: new_board}
    {:noreply, new_state}
  end

  def handle_cast({:remove_animal, animal, coordinates}, state = %{board: board}) do
    new_board = CarrotWorld.remove_animal(board, animal, coordinates)
    new_state = %CarrotWorld{state | board: new_board}
    {:noreply, new_state}
  end

  def handle_info(:world_tick, state = %{board: board}) do
    %{wolf_count: wolf_count, rabbit_count: rabbit_count, carrot_count: carrot_count} = CarrotWorld.counts(board)
    CarrotWorld.board_to_graphics(board)
    |> Enum.each(fn(row) -> IO.puts(Enum.join(row, " ")) end)
    
    IO.puts ""
    IO.puts ""
    IO.puts "Wolf:    #{wolf_count}"
    IO.puts "Rabbits: #{rabbit_count}"
    IO.puts "Carrots: #{carrot_count}"
    {:noreply, state}
  end

  def spawn_rabbit(board_size) do
    coordinates = %{x: 6, y: 6}

    Rabbit.start(coordinates, board_size: board_size)
  end

  def spawn_wolf(board_size) do
    coordinates = %{x: 0, y: 0}

    Wolf.start(coordinates, board_size: board_size)
  end

  
end
