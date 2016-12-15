defmodule ProfileControl do
  use GenServer


  ## Client API
  def start_link(opts \\ []) do
    profile = [%{:duration => nil, :start => 20}]
    GenServer.start_link(__MODULE__, profile, opts)
  end

  def current_temp(controllerPID) do
    GenServer.call(controllerPID, :soll)
  end


  #Server Callbacks

  def init(profile) do
    profile_stage = 0
    seconds_elapsed = 0  
    {:ok, {profile_stage, seconds_elapsed, profile}}
  end

  def handle_call(:soll, _from, state) do
    # just set it to 20 for now.
    soll = Application.get_env( :fmeister, :soll, 20)
    {:reply, soll, state}
  end
end

