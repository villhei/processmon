defmodule Processmon do

  use Application

  def start(_type, _args) do
    Processmon.Supervisor.start_link()
  end

end
