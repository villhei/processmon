defmodule Processmon do

  use Application

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [
        {"/", :cowboy_static, {:priv_file, :processmon, "index.html"}},
        {"/static/[...]", :cowboy_static, {:priv_dir,  :cowboy_elixir_example, "static_files"}},
        {"/websocket", WebsocketHandler, []}
      ]}
    ])
    {:ok, _} = :cowboy.start_http(:http_listener, 100, [port: 8080], [env: [dispatch: dispatch]])
    Processmon.Supervisor.start_link()
  end

end
