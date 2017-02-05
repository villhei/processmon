defmodule Processmon.Monitor do
  use GenServer

  defstruct cpu_usage: [], cpu_users: [], mem_usage: []

  alias Porcelain.Result
  alias Processmon.SubscriptionManager
  alias __MODULE__, as: Monitor

  @cpu_usage_command "scripts/cpu_usage.sh" #"mpstat -P ALL"
  @cpu_users_command "scripts/cpu_users.sh" # "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
  @memory_usage_command "scripts/mem.sh" #"free"

  ### Client API

  @doc """
  Stars the htop process monitor
  """

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Fetches the monitor output of given server
  """

  def get_stream(server) do
    GenServer.call(server, :get_stream)
  end

  def init(:ok) do
    IO.puts("Starting the monitor process")
    _ref = schedule_next_update()
    {:ok, %Monitor{}}
  end

  def handle_info(:update, _state) do
    %Result{out: memory, status: 0} = Porcelain.shell(@memory_usage_command)
    %Result{out: cpu_usage, status: 0} = Porcelain.shell(@cpu_usage_command)
    %Result{out: cpu_users, status: 0} = Porcelain.shell(@cpu_users_command)
    _ref = schedule_next_update()
    new_state = %Monitor{cpu_usage: cpu_usage, cpu_users: cpu_users, mem_usage: memory}
    SubscriptionManager.update(encode(new_state))
    {:noreply, new_state}
  end

  defp encode(new_state) do
    (%Monitor{
      cpu_usage: Poison.decode!(new_state.cpu_usage),
      cpu_users: Poison.decode!(new_state.cpu_users),
      mem_usage: Poison.decode!(new_state.mem_usage)
    })
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  defp schedule_next_update() do
    Process.send_after(self(), :update, 1000)
  end

end