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

  def report(target, reporter, payload) do
    GenServer.cast(target, {:report, {reporter, payload}})
  end

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
    new_state = remove_old(state)
    :ok = SubscriptionManager.update(remove_timestamps(new_state))
    _ref = schedule_next_update()
    {:noreply, state}
  end

  defp remove_timestamps(state) do
    state 
    |> Map.keys() 
    |> Enum.map(fn key -> 
      values = Map.get(state, key)
      payload = Map.get(values, :payload)
      {key, payload}
    end)
    |>
    Enum.reduce(%{}, fn({key, payload}, acc) -> 
      Map.put(acc, key, payload) 
    end)

  end

  defp remove_old(state) do
    time = :os.system_time(:milli_seconds)
    timeout = 1000 * 5

    remove_older = time - timeout
    state 
      |> Map.keys() 
      |> Enum.filter(fn host -> 
        values = Map.get(state, host)
        values[:time] > remove_older 
      end) 
      |> Enum.reduce(%{}, fn(key, acc) -> 
        Map.put(acc, key, Map.get(state, key))
      end)
  end
  
  def handle_cast({:report, {reporter, payload}}, state) do
    time = :os.system_time(:milli_seconds)

    new_state = state 
      |> Map.put(reporter, %{:time => time, :payload => payload } )

    {:noreply, new_state}
  end

  def handle_cast({:update, payload}, state) do
    state |> Enum.each(fn {subscriber, _} ->
      send(subscriber, {:update, payload}) end)
    {:noreply, state}
  end

end