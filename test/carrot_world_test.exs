defmodule CarrotWorldTest do
  use ExUnit.Case
  
  setup do
    %CarrotWorld{board: simple_board} = CarrotWorld.build_initial_world(%{board_size: 2})

    first_row = [[{1, :rabbit}, {1, :wolf}, {1, :rabbit}, {1, :carrots}], [{1, :rabbit}, {1, :rabbit}, {1, :carrots}]]
    second_row = [[{1, :carrots}], [{1, :no_carrots}]]

    complex_board = List.replace_at(simple_board, 0, first_row) |> List.replace_at(1, second_row)

    {:ok, [complex_board: complex_board, simple_board: simple_board]}
  end

  test "build_initial_world" do
    %CarrotWorld{board: board} = CarrotWorld.build_initial_world(%{board_size: 2})

    assert length(board) == 2
    assert length(List.first(board)) == 2

    status_grid = Enum.map(board, fn(row) -> 
      Enum.map(row, fn(elem) -> 
        [{_, status}] = elem
        status
       end) 
    end)
    

    assert status_grid == [[:no_carrots, :no_carrots], [:no_carrots, :no_carrots]]
  end

  test "print_board (blank)" do
    %CarrotWorld{board: board} = CarrotWorld.build_initial_world(%{board_size: 2})
    graphical_board = CarrotWorld.board_to_graphics(board)

    assert graphical_board == [[" ", " "], [" ", " "]]
  end

  test "print_board (multiple occupants)", context do
    carrot_board = context[:complex_board]

    graphical_board = CarrotWorld.board_to_graphics(carrot_board)

    assert graphical_board == [["W", "+"], [".", " "]]
  end

  test "update carrot status with replace_at", context do
    graphical_board = context[:complex_board]
    |> CarrotWorld.replace_at(%{x: 1, y: 1}, :carrots)
    |> CarrotWorld.replace_at(%{x: 0, y: 1}, :no_carrots)
    |> CarrotWorld.board_to_graphics

    assert graphical_board == [["W", "+"], [" ", "."]]
  end

  test "update animal position with move and remove", context do
    {:ok, wolf} = GenServer.start_link(Wolf, %{current_coordinates: %{x: 1, y: 1}, board_size: 2})

    wolf_tuple = {wolf, :wolf}

    board = context[:complex_board]
    |> CarrotWorld.move_animal(wolf_tuple, %{x: 1, y: 1})

    graphical_board = CarrotWorld.board_to_graphics(board)

    assert graphical_board == [["W", "+"], [".", "W"]]

    graphical_board = board |> CarrotWorld.remove_animal(wolf_tuple, %{x: 1, y: 1}) |> CarrotWorld.board_to_graphics

    assert graphical_board == [["W", "+"], [".", " "]]
  end

  test "find carrot patch with coordinates", context do
    patch = CarrotWorld.get_patch_at(context[:simple_board], %{x: 0, y: 0})
    assert Process.alive?(patch)
  end

  test "wolf eats rabbits", context do
    {:ok, wolf} = GenServer.start_link(Wolf, %{current_coordinates: %{x: 1, y: 1}, board_size: 2})
    {:ok, rabbit} = GenServer.start_link(Rabbit, %{current_coordinates: %{x: 1, y: 1}, board_size: 2})

    wolf_tuple = {wolf, :wolf}
    rabbit_tuple = {rabbit, :rabbit}

    board = context[:simple_board]
    |> CarrotWorld.move_animal(wolf_tuple, %{x: 1, y: 1})
    |> CarrotWorld.move_animal(rabbit_tuple, %{x: 1, y: 1})

    graphical_board = CarrotWorld.board_to_graphics(board)

    assert graphical_board == [[" ", " "], [" ", "W"]]

    {reply, board} = board |> CarrotWorld.wolf_eat_rabbit(%{x: 1, y: 1})

    graphical_board = CarrotWorld.board_to_graphics(board)

    assert reply == {:ok, true}
    assert graphical_board == [[" ", " "], [" ", "W"]]

    #
    # to let the rabbit process die
    #
    :timer.sleep(100)

    assert Process.alive?(rabbit) == false    
  end

  test "animal and carrot counts", context do
    %{wolf_count: wolf_count, rabbit_count: rabbit_count, carrot_count: carrot_count} = CarrotWorld.counts(context[:complex_board])
    
    assert wolf_count == 1
    assert rabbit_count == 4
    assert carrot_count == 3
  end

  test "build_local_board_for animal" do
    %CarrotWorld{board: board} = CarrotWorld.build_initial_world(%{board_size: 10})

    wolf_coordinates = %{x: 5, y: 5}
    rabbit_coordinates = %{x: 5, y: 3}

    {:ok, wolf} = GenServer.start_link(Wolf, %{current_coordinates: wolf_coordinates, board_size: 10})
    {:ok, rabbit} = GenServer.start_link(Rabbit, %{current_coordinates: rabbit_coordinates, board_size: 10})

    wolf_tuple = {wolf, :wolf}
    rabbit_tuple = {rabbit, :rabbit}

    new_board = board
    |> CarrotWorld.move_animal(wolf_tuple, wolf_coordinates)
    |> CarrotWorld.move_animal(rabbit_tuple, rabbit_coordinates)


    local_board = CarrotWorld.build_local_board_for(:wolf, %{coordinates: wolf_coordinates, board: new_board})
    |> Enum.map(fn(row) -> 
         Enum.map(row, fn(occupants) -> 
            Enum.filter(occupants, fn(status) ->
              status == :rabbit || status == :wolf
            end)
         end)
       end)

    assert length(local_board) == 7

    expected_result = [
                        [[], [], [], [], [], [], []], 
                        [[], [], [], [:rabbit], [], [], []],
                        [[], [], [], [], [], [], []],
                        [[], [], [], [:wolf], [], [], []],
                        [[], [], [], [], [], [], []],
                        [[], [], [], [], [], [], []],
                        [[], [], [], [], [], [], []]
                      ]

    assert local_board == expected_result
  end

  
end