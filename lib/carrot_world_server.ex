require IEx

defmodule CarrotWorldServer do
  use GenServer

  @world_tick 100

  def start(%{board_size: board_size}) do
    GenServer.start_link(CarrotWorldServer, %{board_size: board_size}, name: :carrot_world_server)
    {:ok, :carrot_world_server}
  end

  def start_in_production do
    start(%{board_size: 35})
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

  def init(%{board_size: board_size}) do
    state = CarrotWorld.build_initial_world(%{board_size: board_size})
    spawn_wolf(state)
    spawn_rabbit(state)
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

    send_local_board_to_animal(animal, coordinates, new_board)

    {:noreply, new_state}
  end

  def send_local_board_to_animal({pid, :rabbit}, coordinates, board) do
    local_board_for_animal = CarrotWorld.build_local_board_for(:rabbit, %{coordinates: coordinates, board: board})
    GenServer.cast(pid, {:new_local_board, %{local_board: local_board_for_animal}})
  end

  def send_local_board_to_animal({pid, :wolf}, coordinates, board) do
    local_board_for_animal = CarrotWorld.build_local_board_for(:wolf, %{coordinates: coordinates, board: board})
    GenServer.cast(pid, {:new_local_board, %{local_board: local_board_for_animal}})
  end

  def handle_cast({:remove_animal, animal, coordinates}, state = %{board: board}) do
    new_board = CarrotWorld.remove_animal(board, animal, coordinates)
    new_state = %CarrotWorld{state | board: new_board}
    {:noreply, new_state}
  end

  def handle_info(:world_tick, state = %{board: board}) do
    %{wolf_count: wolf_count, rabbit_count: rabbit_count, carrot_count: carrot_count} = CarrotWorld.counts(board)

    wolf_meter = meterize(wolf_count)
    rabbit_meter = meterize(rabbit_count)
    carrot_meter = meterize(carrot_count)

    CarrotWorld.board_to_graphics(board)
    |> Enum.each(fn(row) -> IO.puts(Enum.join(row, " ")) end)
    
    IO.puts ""
    IO.puts ""
    IO.puts "Wolf:    #{wolf_count} #{wolf_meter}"
    IO.puts "Rabbits: #{rabbit_count} #{rabbit_meter}"
    IO.puts "Carrots: #{carrot_count} #{carrot_meter}"
    {:noreply, state}
  end

  def meterize(integer) do
    meter_length = Enum.max([div(integer, 10) - 1, 0])
    Enum.to_list(0..meter_length)
    |> Enum.map(fn(_) -> "|" end)
    |> Enum.join
  end

  def spawn_rabbit(%{board_size: board_size}) do
    coordinates = %{x: 6, y: 6}
    Rabbit.start(%{current_coordinates: coordinates, board_size: board_size})
  end

  def spawn_wolf(%{board_size: board_size}) do
    coordinates = %{x: 0, y: 0}
    Wolf.start(%{current_coordinates: coordinates, board_size: board_size})
  end

  
end
