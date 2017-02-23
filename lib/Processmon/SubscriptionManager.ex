defmodule Processmon.SubscriptionManager do
  use GenServer

  ### Client API

  @doc """
  Starts the SubscriptionManager process
  """

  def start_link(name \\ Processmon.SubscriptionManager) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
    Subscribe to SubscriptionManager process
  """

  def subscribe(subscriber) when is_pid(subscriber) do
    GenServer.cast(__MODULE__, {:subscribe, subscriber})
  end

  @doc """
    Unsubscribe from a SubscriptionManager process
  """

  def unsubscribe(subscriber) when is_pid(subscriber) do
    GenServer.cast(__MODULE__, {:unsubscribe, subscriber})
  end

  @doc """
    Share something with subscribers
  """

  def update(payload) do
    GenServer.cast(__MODULE__, {:update, payload})
  end

  ### Callbacks

  def init(:ok) do
    IO.puts("Starting the SubscriptionManager process")
    {:ok, %{}}
  end

  def handle_cast({:subscribe, subscriber}, state) do
    IO.puts("Received a new subscriber#{inspect(subscriber)}")
    {:noreply, Map.put(state, subscriber, nil)}
  end

  def handle_cast({:unsubscribe, subscriber}, state) do
    {:noreply, Map.drop(state, [subscriber])}
  end

  def handle_cast({:update, payload}, state) do
    state |> Enum.each(fn {subscriber, _} ->
      send(subscriber, {:update, payload}) end)
    {:noreply, state}
  end

end