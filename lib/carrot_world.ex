require IEx
defmodule CarrotWorld do

  defstruct [:board]

  @carrot_graphic "."
  @rabbit_graphic "+"
  @wolf_graphic "W"

  def build_initial_world({:board_size, board_size}) do
    carrot_patches = spawn_carrot_patches({:board_size, board_size})

    board = carrot_patches
    |> Enum.map(fn(row) -> Enum.map(row, fn(occupant) -> [occupant] end) end)

    %CarrotWorld{board: board}
  end

  def board_to_graphics(board) do
    board
    |> Enum.map(fn(row) -> 
        Enum.map(row, fn(occupants) -> 
          graphic_for_occupants(occupants) 
      end) 
    end)
  end

  def get_patch_at(board, coordinates) do
    occupants_at(board, coordinates) 
    |> Enum.filter(fn({_, status}) -> (status == :carrots || status == :no_carrots) end)
    |> List.first
    |> elem(0)
  end

  def wolf_eat_rabbit(board, coordinates = coordinates) do
    occupants = occupants_at(board, coordinates)

    rabbits = Enum.filter(occupants, fn({_, animal_name}) -> animal_name == :rabbit end)
   
    cond do
      length(rabbits) > 0 ->
        rabbit_tuple = List.first(rabbits)
        {rabbit, _} = rabbit_tuple
        
        Rabbit.eaten_by_wolf(rabbit)
        new_occupants = List.delete(occupants, rabbit_tuple)
        
        got_some_rabbits = true
        board = replace_occupants(board, new_occupants, coordinates)

      :else ->
        got_some_rabbits = false
        board = board
    end

    reply = {:ok, got_some_rabbits}
    {reply, board}
  end

  def replace_at(board, coordinates, new_status) do
    occupants = occupants_at(board, coordinates)

    new_occupants = Enum.map(occupants, fn({pid, status}) -> 
      cond do
        status == new_status -> {pid, status}
        :else ->
          cond do
            status == :carrots -> {pid, new_status}
            status == :no_carrots -> {pid, new_status}
            :else -> {pid, status}
          end
      end
    end)

    replace_occupants(board, new_occupants, coordinates)
  end 

  def move_animal(board, animal, coordinates) do
    occupants = occupants_at(board, coordinates)

    new_occupants = [animal | occupants]

    replace_occupants(board, new_occupants, coordinates)
  end

  def remove_animal(board, animal, coordinates) do
    occupants = occupants_at(board, coordinates)

    new_occupants = List.delete(occupants, animal)

    replace_occupants(board, new_occupants, coordinates)
  end


  # ========= Private Functions

  defp replace_occupants(board, new_occupants, %{x: x, y: y}) do
    row = Enum.at(board, x)
    new_row = List.replace_at(row, y, new_occupants)
    List.replace_at(board, x, new_row) 
  end 

  defp occupants_at(board, %{x: x, y: y}) do
    Enum.at(board, x) |> Enum.at(y)
  end

  defp graphic_for_occupants(occupants) do
    status_list = Enum.map(occupants, fn({_, status}) -> status end)
    cond do
      Enum.member?(status_list, :wolf) -> @wolf_graphic
      Enum.member?(status_list, :rabbit) -> @rabbit_graphic
      Enum.member?(status_list, :carrots) -> @carrot_graphic
      :else -> " "
    end
  end

  def spawn_carrot_patches({:board_size, board_size}) do
    board_size_less_one = board_size - 1
    Enum.to_list(0..board_size_less_one)
    |> Enum.map(fn(x) -> 
      Enum.to_list(0..board_size_less_one) |> Enum.map(fn(y) -> 
        {:ok, carrot_patch} = CarrotPatch.start(%{x: x, y: y, board_size: board_size}) 
        {carrot_patch, :no_carrots}
      end)
    end)
  end
  
  
end