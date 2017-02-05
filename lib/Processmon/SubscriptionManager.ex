defmodule Processmon.SubscriptionManager do
  use GenServer

  ### Client API

  @doc """
  Stars the htop process monitor
  """

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Fetches the monitor output of given server
  """

  def subscribe(subscriber) do
    GenServer.cast(__MODULE__, {:subscribe, subscriber})
  end

  def unsubscribe(subscriber) do
    GenServer.cast(__MODULE__, {:unsubscribe, subscriber})
  end

  def update(payload) do
    GenServer.cast(__MODULE__, {:update, payload})
  end

  ### Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:subscribe, subscriber}, state) do
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