require IEx

defmodule CarrotPatch do
  import CarrotPatch.Grower
  import CarrotPatch.Killer

  # use GenServer

  defstruct [:has_carrots, :x, :y, :carrot_growth_points, :carrot_age, :occupants, :board_size]

  @emoji_number 127823
  @grow_tick_interval 500
  @carrot_growth_points_required 100

  def start(%{x: x, y: y, board_size: board_size}) do
    {:ok, pid} = GenServer.start_link(CarrotPatch, %{x: x, y: y, board_size: board_size})
    :timer.send_interval(@grow_tick_interval, pid, :grow_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  def eat_carrots(pid) do
    response = GenServer.call(pid, :eat_carrots)
    {:ok, response}
  end  
  

  # =============== Server Callbacks

  def init(%{x: x, y: y, board_size: board_size}) do
    seed = {x+y, :erlang.monotonic_time, :erlang.unique_integer}
    :random.seed(seed)
    carrot_growth_points = :random.uniform(@carrot_growth_points_required)
    {:ok, %CarrotPatch{has_carrots: false, x: x, y: y, carrot_growth_points: carrot_growth_points, carrot_age: 0, board_size: board_size}}
  end

  def handle_info(:grow_tick, state) do
    {:noreply, tick_world(state)}
  end

  def handle_call({:get, :coordinates}, _, state = %CarrotPatch{x: x, y: y}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def handle_call(:eat_carrots, _, state = %CarrotPatch{}) do
    {reply, new_state} = do_eat_carrots(state)
    {:reply, reply, new_state}
  end  

  # =============== Private functions

  def do_eat_carrots(state = %CarrotPatch{has_carrots: has_carrots}) do
    cond do
      has_carrots ->
        new_state = %{state | has_carrots: false, carrot_growth_points: 0, carrot_age: 0}
        update_world(new_state)
        {true, new_state}
      :else ->
        {false, state}
    end
  end

  defp tick_world(state = %{has_carrots: old_has_carrots}) do
    new_state = state
    |> grow_and_recognize_new_carrots
    |> age_existing_and_kill_carrots

    %{has_carrots: new_has_carrots} = new_state

    if new_has_carrots != old_has_carrots do
      update_world(new_state)
    end

    new_state
  end

  defp update_world(%CarrotPatch{x: x, y: y, has_carrots: has_carrots}) do
    cond do
      has_carrots -> CarrotWorldServer.put_patch(%{x: x, y: y, status: :carrots})
      :else -> CarrotWorldServer.put_patch(%{x: x, y: y, status: :no_carrots})
    end
  end

end