defmodule CarrotPatch do
  import CarrotPatch.Grower
  import CarrotPatch.Killer

  defstruct [:has_carrots, :x, :y, :carrot_growth_points, :carrot_age]

  @emoji_number 127823
  @grow_tick_interval 500
  @update_world_interval 1000
  @carrot_growth_points_required 100
  @carrot_growth_point_speed 10
  @carrot_life_span 35

  def start(%{x: x, y: y}) do
    {:ok, pid} = GenServer.start_link(CarrotPatch, %{x: x, y: y})
    :timer.send_interval(@grow_tick_interval, pid, :grow_tick)
    :timer.send_interval(@update_world_interval, pid, :update_world_tick)
    {:ok, pid}
  end

  def has_carrots?(pid) do
    GenServer.call(pid, {:get, :has_carrots})
  end

  def grow_carrots(pid) do
    GenServer.cast(pid, {:put, :new_carrots})
  end

  def remove_carrots(pid) do
    GenServer.cast(pid, {:put, :remove_carrots})
  end

  def to_screen({:has_carrots, has_carrots}) do
    cond do
      has_carrots -> "1"
      :else -> "0"
    end
  end

  def to_screen(pid) do
    has_carrots = GenServer.call(pid, {:get, :has_carrots})
    to_screen({:has_carrots, has_carrots})
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end
  
  

  # =============== Server Callbacks

  def init(%{x: x, y: y}) do
    seed = {x+y, :erlang.monotonic_time, :erlang.unique_integer}
    :random.seed(seed)
    carrot_growth_points = :random.uniform(@carrot_growth_points_required)
    {:ok, %CarrotPatch{has_carrots: false, x: x, y: y, carrot_growth_points: carrot_growth_points, carrot_age: 0}}
  end

  def handle_info(:grow_tick, state) do
    {:noreply, tick_world(state)}
  end

  def handle_info(:update_world_tick, state) do
    {:noreply, update_world(state)}
  end

  def handle_call({:get, :has_carrots}, _, state = %CarrotPatch{has_carrots: has_carrots}) do
    {:reply, has_carrots, state}
  end

  def handle_call({:get, :coordinates}, _, state = %CarrotPatch{x: x, y: y}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def handle_cast({:put, :new_carrots}, state = %CarrotPatch{}) do
    new_state = %CarrotPatch{state | :has_carrots => true}
    {:noreply, new_state}
  end

  def handle_cast({:put, :remove_carrots}, state = %CarrotPatch{}) do
    new_state = %CarrotPatch{state | :has_carrots => false}
    {:noreply, new_state}
  end

  def terminate(reason, state) do
    IO.puts " ----------- "
    IO.inspect self
    IO.inspect reason
    :ok
  end
  

  # =============== Private functions

  defp tick_world(state) do
    state
    |> grow_and_recognize_new_carrots    
    |> age_existing_and_kill_carrots
  end

  defp update_world(state = %CarrotPatch{x: x, y: y, has_carrots: has_carrots}) do
    graphics = CarrotPatch.to_screen({:has_carrots, has_carrots})
    CarrotWorldServer.put_patch(%{x: x, y: y, graphics: graphics})
    state
  end

end