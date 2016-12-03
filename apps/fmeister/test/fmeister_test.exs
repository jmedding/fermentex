defmodule FmeisterTest do
  use ExUnit.Case
  doctest Fmeister

  setup do
    :ok
  end

  test "fmeister integration test" do
    {:ok, t_read} = TempReader.start_link
    {:ok, t_control} = TestTempControl.start_link
    {:ok, profile} = ProfileControl.start_link

    # Fmeister.init(profile, t_control, t_read)
    assert TempReader.set(t_read, 25) == :ok
    {state, _} = TempControl.get_state(t_control)
    assert state == :off

  end

  test "Decide which temp control action to take" do
    soll = 20.0
    assert Fmeister.get_control_action(:heat, soll,  21) == :stop
    assert Fmeister.get_control_action(:heat, soll,  19) == :hotter
    assert Fmeister.get_control_action(:cool, soll,  21) == :colder
    assert Fmeister.get_control_action(:cool, soll,  19) == :stop
    assert Fmeister.get_control_action(:off, soll,  21) == :stop
    assert Fmeister.get_control_action(:off, soll,  19) == :stop
    assert Fmeister.get_control_action(:off, soll,  23) == :colder
    assert Fmeister.get_control_action(:off, soll,  17) == :hotter
    assert Fmeister.get_control_action(:error, soll,  19) == :stop
  end

  test "Fmeister acts accordingly" do
    {:ok, t_control} = TestTempControl.start_link
    t = 10   # elapsed time in seconds
    soll = 20.0
    test_fmeister_act(soll, 15, t_control, :heat, t) # too cold
    test_fmeister_act(soll, 25, t_control, :off, t)  # done heating
    test_fmeister_act(soll, 25, t_control, :cool, t) # to hot
    test_fmeister_act(soll, 15, t_control, :off, t)  # done cooling
    test_fmeister_act(soll, 15, t_control, :heat, t) # too cold
    test_fmeister_act(soll, 21, t_control, :off, t)  # done heating
    test_fmeister_act(soll, 19, t_control, :off, t)  # just right

    result = Fmeister.act(:error, "TestErrorMsg", t_control, t)
    assert result = :ok
  end
    
  defp test_fmeister_act(soll, ist, t_control, new_state, elapsed_time) do
    Fmeister.act(soll, ist, t_control, elapsed_time)
    {state, _} = TestTempControl.get_state(t_control)
    assert state == new_state
  end
end
