defmodule Processmon.ReportCollector do
  use GenServer
  alias Processmon.SubscriptionManager

  ### Client API

  @doc """
  Starts the ReportCollector process
  """

  def start_link() do
    {:ok, _} = GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
    Broadcast the report
  """

  def report(reporter, payload) do
    GenServer.cast(__MODULE__, {:report, {reporter, payload}})
  end

  ### Callbacks

  def init(:ok) do
    _ref = schedule_next_update()
    {:ok, %{}}
  end

  defp schedule_next_update() do
      Process.send_after(self(), :broadcast, 1_000)
  end

  def handle_info(:broadcast, state) do
    IO.puts("Broadcasting")
    :ok = SubscriptionManager.update(state)
    _ref = schedule_next_update()
    {:noreply, state}
  end

  def handle_info({:update, {reporter, payload}}, state) do
    {:noreply, state |> Map.put(reporter, payload) }
  end
  
  def handle_cast({:report, {reporter, payload}}, state) do
    {:noreply, state |> Map.put(reporter, payload) }
  end

  def handle_cast({:update, payload}, state) do
    state |> Enum.each(fn {subscriber, _} ->
      send(subscriber, {:update, payload}) end)
    {:noreply, state}
  end

end