defmodule Fmeister do
  require Logger

  @temp_control Application.get_env(:fmeister, :temp_control)
  @temp_sense Application.get_env(:fmeister, :temp_sense)
  
  #TODO: Put elapsed time in an Agent so we don't loose it on restart
  def init(profile, t_control, t_read) do
    state = %{elapsed_time: 0}
    IO.puts inspect @temp_sense
    run(profile, t_control, t_read, state)
  end

  def run(profile, t_control, t_read, state) do
    soll = ProfileControl.current_temp(profile)
    case TempReader.read(t_read) do
      {:error, msg} -> act(:error, msg, t_control, state.elapsed_time)
      data-> act(soll, data.value, t_control, state.elapsed_time)
    end
    freq = 30
    :timer.sleep(freq * 1000)
    t = state.elapsed_time + freq
    run(profile, t_control, t_read, %{state | elapsed_time: t})
  end

  def act(:error, msg, t_control, elapsed_time) do
    @temp_control.make_it(t_control,:stop)
    Logger.error "Time: #{elapsed_time}, ERROR - STOPPING TEMP CONTROL: " <> msg
  end
  
  def act(soll, ist, t_control, elapsed_time) do
    {state, _} = @temp_control.get_state(t_control)
    action = get_control_action(state, soll, ist)
    Logger.info "Time: #{elapsed_time}, Current State: #{state}, Soll: #{soll}, Ist: #{ist}, Action: #{action}"
    @temp_control.make_it(t_control, action)

  end

  def get_control_action(state, soll, ist) do

    case {state, soll, ist} do
      {:heat, soll, ist} when ist  > soll        -> :stop
      {:heat, soll, ist} when ist <= soll        -> :hotter
      {:cool, soll, ist} when ist  > soll        -> :colder
      {:cool, soll, ist} when ist <= soll        -> :stop
      {:off, soll, ist}  when ist  > soll * 1.1  -> :colder
      {:off, soll, ist}  when ist <= soll * 0.9  -> :hotter
      _                                          -> :stop
    end
  end


end
