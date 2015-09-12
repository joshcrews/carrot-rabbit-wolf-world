
defmodule CarrotPatch do

  defstruct [:has_carrots]

  @moduletag emoji_number: 127823

  def start do
    {:ok, pid} = GenServer.start_link(CarrotPatch, [])
  end

  def has_carrots?(pid) do
    GenServer.call(pid, {:get, :has_carrots})
  end

  def grow_carrots(pid) do
    GenServer.cast(pid, {:put, :new_carrots})
  end

  # ===================================

  def init(_) do
    {:ok, %CarrotPatch{has_carrots: false}}
  end

  def handle_call({:get, :has_carrots}, _, state = %CarrotPatch{has_carrots: has_carrots}) do
    {:reply, has_carrots, state}
  end

  def handle_cast({:put, :new_carrots}, state = %CarrotPatch{has_carrots: has_carrots}) do
    new_state = %CarrotPatch{state | :has_carrots => true}
    {:noreply, new_state}
  end
  
end