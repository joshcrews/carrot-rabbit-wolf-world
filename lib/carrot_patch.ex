require IEx

defmodule CarrotPatch do
  import CarrotPatch.Grower
  import CarrotPatch.Killer

  # use GenServer

  defstruct [:has_carrots, :x, :y, :carrot_growth_points, :carrot_age, :occupants, :board_size]

  @emoji_number 127823
  @grow_tick_interval 500
  @update_world_interval 1000
  @carrot_growth_points_required 100
  @carrot_graphic "."
  @rabbit_graphic "R"
  @wolf_graphic "W"

  def start(%{x: x, y: y, board_size: board_size}) do
    {:ok, pid} = GenServer.start_link(CarrotPatch, %{x: x, y: y, board_size: board_size})
    :timer.send_interval(@grow_tick_interval, pid, :grow_tick)
    :timer.send_interval(@update_world_interval, pid, :update_world_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  def eat_carrots(pid) do
    response = GenServer.call(pid, :eat_carrots)
    {:ok, response}
  end

  def eat_rabbits(pid) do
    response = GenServer.call(pid, :eat_rabbits)
    {:ok, response}
  end

  def occupant_arrived({carrot_patch, occupant}) do
    GenServer.cast(carrot_patch, {:put, {:occupant, occupant}})
  end

  def occupant_left({carrot_patch, occupant}) do
    GenServer.cast(carrot_patch, {:delete, {:occupant, occupant}})
  end
  
  def to_screen(%{has_carrots: has_carrots, occupants: [occupant | tail]}) do
    {animal, animal_name} = occupant
    cond do
      animal_name == :wolf -> @wolf_graphic
      :else -> @rabbit_graphic
    end
  end

  def to_screen(%{has_carrots: has_carrots, occupants: []}) do
    cond do
      has_carrots -> @carrot_graphic
      :else ->       " "
    end
  end
  
  

  # =============== Server Callbacks

  def init(%{x: x, y: y, board_size: board_size}) do
    seed = {x+y, :erlang.monotonic_time, :erlang.unique_integer}
    :random.seed(seed)
    carrot_growth_points = :random.uniform(@carrot_growth_points_required)
    {:ok, %CarrotPatch{has_carrots: false, x: x, y: y, carrot_growth_points: carrot_growth_points, carrot_age: 0, board_size: board_size, occupants: []}}
  end

  def handle_info(:grow_tick, state) do
    {:noreply, tick_world(state)}
  end

  def handle_info(:update_world_tick, state) do
    {:noreply, update_world(state)}
  end

  def handle_call({:get, :coordinates}, _, state = %CarrotPatch{x: x, y: y}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def handle_call(:eat_carrots, _, state = %CarrotPatch{}) do
    {reply, new_state} = do_eat_carrots(state)
    {:reply, reply, new_state}
  end

  def handle_call(:eat_rabbits, _, state = %CarrotPatch{}) do
    {reply, new_state} = do_eat_rabbits(state)
    {:reply, reply, new_state}
  end

  def handle_cast({:delete, {:occupant, occupant}}, state = %CarrotPatch{occupants: occupants}) do
    occupant_list = List.delete(occupants, occupant)
    new_state = %CarrotPatch{state | occupants: occupant_list}
    {:noreply, new_state}
  end

  def handle_cast({:put, {:occupant, occupant}}, state = %CarrotPatch{occupants: occupants}) do
    occupant_list = [occupant | occupants]
    new_state = %CarrotPatch{state | occupants: occupant_list}
    {:noreply, new_state}
  end

  def terminate(reason, state) do
    IO.puts "terminated CarrotPatch"
    IO.inspect reason
    IO.inspect state
    :ok
  end

  

  # =============== Private functions

  def do_eat_carrots(state = %CarrotPatch{has_carrots: has_carrots}) do
    cond do
      has_carrots ->
        {true, %{state | has_carrots: false, carrot_growth_points: 0, carrot_age: 0}}
      :else ->
        {false, state}
    end
  end

  def do_eat_rabbits(state = %CarrotPatch{occupants: occupants}) do
    rabbits = Enum.filter(occupants, fn({_, animal_name}) -> animal_name == :rabbit end)

    cond do
      length(rabbits) > 0 ->
        rabbit_tuple = List.first(rabbits)
        {rabbit, _} = rabbit_tuple
        Rabbit.eaten_by_wolf(rabbit)
        new_occupants = List.delete(occupants, rabbit_tuple)
        {true, %{state | occupants: new_occupants}}
      :else ->
        {false, state}
    end
  end

  defp tick_world(state) do
    state
    |> grow_and_recognize_new_carrots    
    |> age_existing_and_kill_carrots
  end

  defp update_world(state = %CarrotPatch{x: x, y: y, has_carrots: has_carrots, occupants: occupants}) do
    graphics = CarrotPatch.to_screen(%{has_carrots: has_carrots, occupants: occupants})
    CarrotWorldServer.put_patch(%{x: x, y: y, graphics: graphics})
    state
  end

end