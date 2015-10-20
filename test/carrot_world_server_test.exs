defmodule CarrotWorldServerTest do
  use ExUnit.Case

  test "spawns rabbit" do
    CarrotWorldServer.start(%{board_size: 10})
    {response, _} = CarrotWorldServer.spawn_rabbit(10)
    assert response == :ok 
  end

  test "spawns wolf" do
    CarrotWorldServer.start(%{board_size: 10})
    {response, _} = CarrotWorldServer.spawn_wolf(10)
    assert response == :ok 
  end


end
