require IEx
defmodule CarrotWorld do
  @timeout 60000
  import Enum, only: [at: 2, count: 1]

  def build_initial_world({:board_size, board_size}) do
    Enum.to_list(1..board_size)
    |> Enum.map(fn(x) -> 
      Enum.to_list(1..board_size) |> Enum.map(fn(y) -> 
        {:ok, carrot_patch} = CarrotPatch.start(%{x: x, y: y}) 
        CarrotPatch.to_screen(carrot_patch)
      end)
    end)
  end






























  def single_carrot_world do
    [
      [0,0,0],
      [0,1,0],
      [0,0,0],
    ]
  end

  def add_rings(world, 0) do
    world
  end

  def add_rings(world, 1) do
    world
    |> insert_row_on_top
    |> insert_row_on_bottom
    |> insert_row_on_left
    |> insert_row_on_right
  end

  def add_rings(world, rings_to_add) do
    next_ring_count_to_add = rings_to_add - 1

    world 
    |> add_rings(1)
    |> add_rings(next_ring_count_to_add)
  end

  def insert_row_on_top(world) do
    row = List.first(world)
    row_size = length(row)
    new_row = Enum.to_list(1..row_size) |> Enum.map(fn(_) -> 0 end)

    [ new_row | world]
  end

  def insert_row_on_bottom(world) do
    world
    |> rotate(90)
    |> rotate(90)
    |> insert_row_on_top
  end

  def insert_row_on_left(world) do
    world
    |> rotate(90)
    |> insert_row_on_top
  end

  def insert_row_on_right(world) do
    world
    |> rotate(90)
    |> rotate(90)
    |> insert_row_on_top
  end

  def rotate(world, 90) do
    rotated_width = count(world)
    rotated_height = count(hd(world))

    for col <- (0..rotated_height-1), into: [] do
      for row <- (rotated_width-1..0), into: [] do
        world |> at(row) |> at(col)
      end
    end
  end
  
  
  
end