defmodule CarrotWorldServerTest do
  use ExUnit.Case

  test "renders empty world" do

    CarrotWorldServer.start(%{board_size: 3})

    correct_map = [
      [" "," "," "],
      [" "," "," "],
      [" "," "," "],
    ]

    assert CarrotWorldServer.render_map == correct_map
  end

  test "receives update from carrot_patch" do
    CarrotWorldServer.start(%{board_size: 3})

    correct_map = [
      ["1"," "," "],
      [" "," "," "],
      [" ","1"," "],
    ]

    CarrotWorldServer.put_patch(%{x: 0, y: 0, graphics: "1"})
    CarrotWorldServer.put_patch(%{x: 2, y: 1, graphics: "1"})

    assert CarrotWorldServer.render_map == correct_map
  end

end
