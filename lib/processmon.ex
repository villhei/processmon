defmodule Processmon do

  use Application

  def start(_type, _args) do

    enable_http? = case System.get_env("ENABLE_HTTP") do
      "false" -> false
      _ -> true
    end

    IO.puts("Enable http? #{inspect(enable_http?)}")

    Processmon.Supervisor.start_link(enable_http?)
  end

end
