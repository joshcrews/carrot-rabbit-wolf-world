defmodule CarrotWorldServer do

  use GenServer

  def start({:board_size, board_size}) do
    GenServer.start_link(CarrotWorldServer, {:board_size, board_size}, name: :carrot_world_server)
  end

  def render_map do
    GenServer.call(:carrot_world_server, {:get, :map})
  end
  

  # ===============

  def init({:board_size, board_size}) do
    {:ok, init_board(board_size)}
  end

  def init_board(board_size) do
    CarrotWorld.build_initial_world({:board_size, board_size})
  end

  def handle_call({:get, :map}, _, state) do
    {:reply, state, state}
  end
  
end
