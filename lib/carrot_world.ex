require IEx
defmodule CarrotWorld do

  defstruct [:board, :board_size]

  @carrot_graphic "."
  @rabbit_graphic "+"
  @wolf_graphic "W"

  def build_initial_world(%{board_size: board_size}) do
    carrot_patches = spawn_carrot_patches(%{board_size: board_size})

    board = carrot_patches
    |> Enum.map(fn(row) -> Enum.map(row, fn(occupant) -> [occupant] end) end)

    %CarrotWorld{board: board, board_size: board_size}
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

  def counts(board) do
    wolf_count = status_list(board) |> Enum.count(fn(x) -> x == :wolf end)
    rabbit_count = status_list(board) |> Enum.count(fn(x) -> x == :rabbit end)
    carrot_count = status_list(board) |> Enum.count(fn(x) -> x == :carrots end)

    %{wolf_count: wolf_count, rabbit_count: rabbit_count, carrot_count: carrot_count}
  end

  def status_map(board) do
    Enum.map(board, fn(row) -> 
      Enum.map(row, fn(occupants) -> 
        Enum.map(occupants, fn({_, status}) -> status end)
      end)
    end)
  end

  def build_local_board_for(_, %{coordinates: %{x: x, y: y}, board: board}) do
    xs = [x - 3, x - 2, x - 1, x, x + 1, x + 2, x + 3] |> only_positives
    ys = [y - 3, y - 2, y - 1, y, y + 1, y + 2, y + 3] |> only_positives

    build_local_board(%{xs: xs, ys: ys, board: board})
  end

  defp build_local_board(%{xs: xs, ys: ys, board: board}) do
    Enum.map(ys, fn(y) -> 
      Enum.map(xs, fn(x) ->
        occupants = Enum.at(board, y, []) |> Enum.at(x, :none)
        cond do
          occupants == :none -> []
          occupants == nil -> []
          :else -> Enum.map(occupants, fn({_, status}) -> status end)
        end
      end)
    end)
  end


  # ========= Private Functions

  defp only_positives(list) do
    Enum.map(list, fn(x) ->
      cond do
        x < 0 -> 999999
        :else -> x
      end
    end)
  end

  defp status_list(grid) do
    List.flatten(status_map(grid))
  end

  defp replace_occupants(board, new_occupants, %{x: x, y: y}) do
    row = Enum.at(board, y)
    new_row = List.replace_at(row, x, new_occupants)
    List.replace_at(board, y, new_row) 
  end 

  defp occupants_at(board, %{x: x, y: y}) do
    Enum.at(board, y) |> Enum.at(x)
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

  def spawn_carrot_patches(%{board_size: board_size}) do
    board_size_less_one = board_size - 1
    Enum.to_list(0..board_size_less_one)
    |> Enum.map(fn(y) -> 
      Enum.to_list(0..board_size_less_one) |> Enum.map(fn(x) -> 
        {:ok, carrot_patch} = CarrotPatch.start(%{x: x, y: y, board_size: board_size}) 
        {carrot_patch, :no_carrots}
      end)
    end)
  end
  
  
end