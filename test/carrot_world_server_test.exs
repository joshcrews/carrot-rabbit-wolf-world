defmodule CarrotWorldServerTest do
  use ExUnit.Case

  test "spawns rabbit" do
    CarrotWorldServer.start(%{board_size: 10})
    {response, _} = CarrotWorldServer.spawn_rabbit(%{board_size: 10})
    assert response == :ok 
  end

  test "spawns wolf" do
    CarrotWorldServer.start(%{board_size: 10})
    {response, _} = CarrotWorldServer.spawn_wolf(%{board_size: 10})
    assert response == :ok 
  end

  test "meterize(int)" do
    assert CarrotWorldServer.meterize(20) == "||"
  end

  test "processes don't bomb out" do
    CarrotWorldServer.sip
    :timer.sleep(1000)
  end 


end
