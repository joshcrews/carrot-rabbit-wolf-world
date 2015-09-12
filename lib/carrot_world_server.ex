defmodule CarrotWorldServer do
  use GenServer

  @world_tick 100

  def start(%{board_size: board_size, world_builder: world_builder}) do
    GenServer.start_link(CarrotWorldServer, {:board_size, board_size, world_builder: world_builder}, name: :carrot_world_server)
    :timer.send_interval(@world_tick, :carrot_world_server, :tick)
    {:ok, :carrot_world_server}
  end

  def start_in_production do
    start(%{board_size: 5, world_builder: CarrotWorld})
  end

  def render_map do
    GenServer.call(:carrot_world_server, {:get, :map})
  end
  
  # ===============

  def init({:board_size, board_size, world_builder: world_builder}) do
    state = world_builder.build_initial_world({:board_size, board_size})
    {:ok, state}
  end

  def handle_call({:get, :map}, _, state) do
    {:reply, state, state}
  end

  def handle_info(:tick, state) do
    IO.inspect state
    {:noreply, state}
  end
  
  
end
