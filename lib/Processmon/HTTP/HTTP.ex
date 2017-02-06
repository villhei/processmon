defmodule Processmon.HTTP do
  
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Standard init
  """

  def init(:ok) do
    IO.puts("Starting the HTTP server process in port 8080")
    start_server()
  end

  def start_server do
    dispatch = :cowboy_router.compile([
      {:_, [
        {"/", :cowboy_static, {:priv_file, :processmon, "index.html"}},
        {"/static/[...]", :cowboy_static, {:priv_dir,  :processmon, "static"}},
        {"/websocket", WebsocketHandler, []}
      ]}
    ])
    {:ok, res} = :cowboy.start_http(:http_listener, 100, [{ip, {127,0,0,1}}, port: 8080], [env: [dispatch: dispatch]])
  end

   ### Callbacks

  def handle_cast(_, state) do
    {:noreply, nil, state}
  end

  def handle_call(_, _from, state) do
    {:noreply, nil, state}
  end

end