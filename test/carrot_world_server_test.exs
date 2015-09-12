defmodule CarrotWorld.Sandbox do
  
  def build_initial_world(_) do
    [
      [0,0,0],
      [0,1,0],
      [0,0,0],
    ]
  end
  
end

defmodule CarrotWorldTest do
  use ExUnit.Case

  test "renders empty world" do
    carrot_world_sandbox = CarrotWorld.Sandbox

    CarrotWorldServer.start(%{board_size: 1, world_builder: carrot_world_sandbox})

    correct_map = [
      [0,0,0],
      [0,1,0],
      [0,0,0],
    ]

    assert CarrotWorldServer.render_map == correct_map
  end

end
