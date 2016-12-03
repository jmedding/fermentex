defmodule TestTempControl do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

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

  ## Server Callbacks
  def init(:ok) do
    {:ok, {:off, %{}}}
  end

  def handle_call(:colder, _from, _state) do
    {:reply, :ok, {:cool, %{}}}
  end

  def handle_call(:hotter, _from, _state) do
    {:reply, :ok, {:heat, %{}}}
  end

  def handle_call(:stop, _from, _state) do
    {:reply, :ok, {:off, %{}}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

end