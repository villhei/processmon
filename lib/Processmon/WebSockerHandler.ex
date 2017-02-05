defmodule WebsocketHandler do

  alias Processmon.SubscriptionManager

  @behaviour :cowboy_websocket

  # We are using the regular http init callback to perform handshake.
  #     http://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_handler/
  #
  # Note that handshake will fail if this isn't a websocket upgrade request.
  # Also, if your server implementation supports subprotocols,
  # init is the place to parse `sec-websocket-protocol` header
  # then add the same header to `req` with value containing
  # supported protocol(s).
  
  @doc """
  Subscribe the websocket on start
  """

  def init(req, state) do
    SubscriptionManager.subscribe(self())
    {:cowboy_websocket, req, state}
  end

  @doc """
  Unsubscribe the websocket on exit
  """
  def terminate(_reason, _req, _state) do
    SubscriptionManager.unsubscribe(self())
    :ok
  end

  @doc """
  Echo handler
  """

  def websocket_handle({:text, content}, req, state) do
    {:reply, {:text, content}, req, state}
  end

  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  @doc """
  Send back the payload from the SubscriptionManager
  """
  def websocket_info({:update, payload}, req, state) do
    { :ok, message } = Poison.encode(payload)
    { :reply, {:text, message}, req, state}
  end

  # fallback message handler
  def websocket_info(_info, _req, state) do
    {:ok, state}
  end

end