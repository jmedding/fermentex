defmodule  Fmeister.Supervisor  do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @temp_control Application.get_env(:fmeister, :temp_control)

  @fmeister_name Fmeister
  @profile_name ProfileControl
  @t_control_name TempControl
  @t_read_name TempReader

  def init(:ok) do
    children = [
      worker(TempReader, [[name: @t_read_name]]),
      worker(@temp_control, [[name: @t_control_name]]),
      worker(ProfileControl, [[name: @profile_name]]),
      worker(Task, [Fmeister, :init, [@profile_name, @t_control_name, @t_read_name]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end