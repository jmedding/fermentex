defmodule TempReader do
  use GenServer
  @temp_sense_mod Application.get_env(:fmeister, :temp_sense_mod)
  @temp_sense_params Application.get_env(:fmeister, :temp_sense_params)
  @temp_sense_name TempSensor

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  set function is just used for simulation and testing
  """
  def set(readerPID, temp) do
    GenServer.call(readerPID, {:set, temp})
  end

  def read(readerPID) do
    GenServer.call(readerPID, :get)
  end

  ## Server callbacks
  def init(:ok) do
    case Mix.env do
      :test -> {:ok, %Sensor.Temp{value: 20.0, unit: "°C"}}
      :prod -> 
        Sensor.Temp.start(@temp_sense_mod, @temp_sense_params, @temp_sense_name)
        {:ok, Sensor.Temp.sense(@temp_sense_name)}
       _    -> {:ok, %Sensor.Temp{value: 22.2, unit: "°C"}}
    end
  end

  def handle_call(:get, _from, state) do
    response = case Mix.env do
      :test -> {:ok, state} 
      :prod -> Sensor.Temp.sense(@temp_sense_name)
       _    -> {:ok, state}
    end

    {:ok, state} = response
    # will crash if response is not ok.
    {:reply, state, state}
  end

  def handle_call({:set, temp}, _from, _state) do
    {:reply, :ok, build_state(temp)}
  end

  defp build_state(temp) do
    {:ok, %Sensor.Temp{value: temp, unit: "°C"}}
  end
end