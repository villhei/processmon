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
  def init(req, state) do
    SubscriptionManager.subscribe(self())
    {:cowboy_websocket, req, state}
  end

  # Put any essential clean-up here.
  def terminate(_reason, _req, _state) do
    SubscriptionManager.unsubscribe(self())
    :ok
  end

  # websocket_handle deals with messages coming in over the websocket,
  # including text, binary, ping or pong messages. But you need not
  # handle ping/pong, cowboy takes care of that.
  def websocket_handle({:text, content}, req, state) do

    # Use JSEX to decode the JSON message and extract the word entered
    # by the user into the variable 'message'.
    { :ok, %{ "message" => message} } = Poison.decode(content)

    # Reverse the message and use JSEX to re-encode a reply contatining
    # the reversed message.JSEX
    rev = String.reverse(message)
    { :ok, reply } = Poison.encode(%{ reply: rev})

    # All websocket callbacks share the same return values.
    # See http://ninenines.eu/docs/en/cowboy/2.0/manual/cowboy_websocket/
    {:reply, {:text, reply}, req, state}
  end

  # Fallback clause for websocket_handle.  If the previous one does not match
  # this one just ignores the frame and returns `{:ok, state}` without
  # taking any action. A proper app should  probably intelligently handle
  # unexpected messages.
  def websocket_handle(_frame, _req, state) do
    {:ok, state}
  end

  # websocket_info is the required callback that gets called when erlang/elixir
  # messages are sent to the handler process. In this example, the only erlang
  # messages we are passing are the :timeout messages from the timing loop.
  #
  # In a larger app various clauses of websocket_info might handle all kinds
  # of messages and pass information out the websocket to the client.
  def websocket_info({:update, payload}, req, state) do

    # encode a json reply in the variable 'message'
    { :ok, message } = Poison.encode(payload)

    # send the new message to the client. Note that even though there was no
    # incoming message from the client, we still call the outbound message
    # a 'reply'.  That makes the format for outbound websocket messages
    # exactly the same as websocket_handle()
    { :reply, {:text, message}, req, state}
  end

  # fallback message handler
  def websocket_info(_info, _req, state) do
    {:ok, state}
  end

end