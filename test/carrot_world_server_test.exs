defmodule CarrotWorldTest do
  use ExUnit.Case

  test "renders empty world" do
    CarrotWorldServer.start({:board_size, 1})
    correct_map = [
                    [0,0,0,0,0],
                    [0,0,0,0,0],
                    [0,0,1,0,0],
                    [0,0,0,0,0],
                    [0,0,0,0,0],
                  ]

    assert CarrotWorldServer.render_map == correct_map
  end

end
