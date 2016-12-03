defmodule TempControl do
  use GenServer

  ## Client API

  @doc """
  Starts the controller

  TODO: Get GPIO pins for heat and cool from the config file.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Give the controller a mode [:colder | :hotter | :stop]
  """
  def make_it(controllerPID, :colder) do
    GenServer.call(controllerPID, :colder)
  end

  def make_it(controllerPID, :hotter) do
    GenServer.call(controllerPID, :hotter)
  end

  def make_it(controllerPID, :stop) do
    GenServer.call(controllerPID, :stop)
  end

  def get_state(controllerPID) do
    GenServer.call(controllerPID, :get_state)
  end

  ## Server callbacks

  def init(:ok) do
    # The state is simply the current action of the controller
    # :cool, :heat, :off and a dict of the PIds for the heater and cooler GPIO pins
    {:ok, coolPID} = Gpio.start_link(20, :output) 
    {:ok, heatPID} = Gpio.start_link(21, :output) 
    {:ok, {:off, %{cool: coolPID, heat: heatPID}}}
  end

  def handle_call(:colder, _from, state) do
    {activate, deactivate} = {0, 1}
    {_current_state, pins} = state
    Gpio.write(pins.heat, deactivate)
    Gpio.write(pins.cool, activate)
    {:reply, :ok, {:cool, pins}}
  end

  def handle_call(:hotter, _from, state) do
    {activate, deactivate} = {0, 1}
    {_current_state, pins} = state
    Gpio.write(pins.cool, deactivate)
    Gpio.write(pins.heat, activate)
    {:reply, :ok, {:heat, pins}}
  end

  def handle_call(:stop, _from, state) do
    {_activate, deactivate} = {0, 1}
    {_current_state, pins} = state
    Gpio.write(pins.heat, deactivate)
    Gpio.write(pins.cool, deactivate)
    {:reply, :ok, {:off, pins}}
  end

  def handle_call(:get_state, _from, state={mode, _pins}) do
    {:reply, mode, state}
  end

end
