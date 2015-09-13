defmodule Rabbit do

  defstruct [:current_carrot_patch]

  # Spawned onto a carrot patch
  #  -> eats any carrots there
  #    -> eating carrot patch resets patch to 0

  # Moves with each tick
  #  moves towards a random adjacent square with carrots
  #    -> cannot occupy a square that has an occupant (rabbit or future animal)
  #    -> eats those carrots
  #  or moves towards an random empty square


  # After eating 5 carrot patches
  #   -> second bunny appears in adjacent square


  # Dies after 50 rounds

  def start(starting_carrot_patch) do
    {:ok, pid} = GenServer.start_link(Rabbit, %{current_carrot_patch: starting_carrot_patch})
  end

  # =============== Server Callbacks

  def init(%{current_carrot_patch: carrot_patch}) do
    CarrotPatch.register_occupant({carrot_patch, self})
    {:ok, %Rabbit{current_carrot_patch: carrot_patch}}
  end
  
  
  
end