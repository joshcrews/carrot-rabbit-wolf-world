defmodule CarrotWorldServer do
  use GenServer

  @world_tick 100

  def start(%{board_size: board_size}) do
    GenServer.start_link(CarrotWorldServer, {:board_size, board_size}, name: :carrot_world_server)
    :timer.send_interval(@world_tick, :carrot_world_server, :tick)
    {:ok, :carrot_world_server}
  end

  def start_in_production do
    start(%{board_size: 10})
  end

  def sip do
    start_in_production
  end
  

  def render_map do
    GenServer.call(:carrot_world_server, {:get, :map})
  end

  def put_patch(%{x: x, y: y, graphics: graphics}) do
    GenServer.cast(:carrot_world_server, {:put_patch, %{x: x, y: y, graphics: graphics}})
  end
  
  
  # ===============

  def init({:board_size, board_size}) do
    state = CarrotWorld.build_initial_world({:board_size, board_size})
    {:ok, state}
  end

  def handle_call({:get, :map}, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:put_patch, %{x: x, y: y, graphics: graphics}}, state) do
    new_state = CarrotWorld.replace_at(state, %{x: x, y: y}, graphics)
    {:noreply, new_state}
  end

  def handle_info(:tick, state) do
    state
    |> Enum.each(fn(row) -> IO.puts(Enum.join(row, " ")) end)

    IO.puts ""
    IO.puts ""
    {:noreply, state}
  end
  
  
end
