defmodule Processmon.Monitor do
  use GenServer

  defstruct cpu_usage: [], cpu_users: [], mem_usage: [], hostname: "localhost"

  alias Porcelain.Result
  alias Processmon.SubscriptionManager
  alias __MODULE__, as: Monitor
  alias __MODULE__.CpuLoad, as: CpuLoad

  @cpu_usage_command "scripts/cpu_usage.sh" #"mpstat -P ALL"
  @cpu_users_command "scripts/cpu_users.sh" # "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
  @memory_usage_command "scripts/mem.sh" #"free"
  @hostname_command "hostname"
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
    %Result{out: hostname, status: 0} = Porcelain.shell(@hostname_command)

    _ref = schedule_next_update()

    state = update_state(cpu_usage, cpu_users, memory, hostname)

    SubscriptionManager.update(state)

    {:noreply, state}
  end

  defp update_state(cpu_usage, cpu_users, mem_usage, hostname) do
    %Monitor{
      cpu_usage: Poison.decode!(cpu_usage) |> Enum.map(&CpuLoad.from_raw(&1)),
      cpu_users: Poison.decode!(cpu_users),
      mem_usage: Poison.decode!(mem_usage),
      hostname: hostname
    }
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  defp schedule_next_update() do
    Process.send_after(self(), :update, 500)
  end

end