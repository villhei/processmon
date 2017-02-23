defmodule Processmon.Monitor do
  use GenServer

  defstruct cpu_usage: [], cpu_users: [], mem_usage: [], uptime: "", hostname: "localhost"

  alias Porcelain.Result
  alias Processmon.ReportCollector
  alias __MODULE__, as: Monitor
  alias __MODULE__.CpuLoad, as: CpuLoad

  @cpu_usage_command "/scripts/cpu_usage.sh" #"mpstat -P ALL"
  @cpu_users_command "/scripts/cpu_users.sh" # "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
  @memory_usage_command "/scripts/mem.sh" #"free"
  @hostname_command "hostname"
  @uptime_command "uptime"

  ### Client API

  @doc """
  Stars the monitor process
  """

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, [name: name])
  end

  @doc """
  Add a broadcast target
  """

  def add_target(target) do
    GenServer.cast(__MODULE__, {:add_target, target})
  end

  @doc """
  Remove a broadcast target
  """

  def remove_target(target) do
    GenServer.cast(__MODULE__, {:remove_target, target})
  end

  @doc """
  Standard init
  """

  def init(:ok) do
    IO.puts("Starting the system monitor process")
    _ref = schedule_next_update()
    report_targets = [{ReportCollector, Node.self()}]
    {:ok, report_targets}
  end

  defp get_path(path) do
     Application.app_dir(:processmon, "priv") <> path 
  end

  @doc """
  The timer loop
  """
    
  def handle_info(:update, report_targets) do
    %Result{out: memory, status: 0} = Porcelain.shell(get_path(@memory_usage_command))
    %Result{out: cpu_usage, status: 0} = Porcelain.shell(get_path(@cpu_usage_command))
    %Result{out: cpu_users, status: 0} = Porcelain.shell(get_path(@cpu_users_command))
    %Result{out: hostname, status: 0} = Porcelain.shell(@hostname_command)
    %Result{out: uptime, status: 0} = Porcelain.shell(@uptime_command)

    _ref = schedule_next_update()

    monitor_results = update_results(cpu_usage, cpu_users, memory, hostname, uptime)

    report_targets 
      |> Enum.each(fn target -> 
        ReportCollector.report(target, Node.self(), monitor_results) 
      end)

    {:noreply, report_targets}
  end

  defp update_results(cpu_usage, cpu_users, mem_usage, hostname, uptime) do

    usage = Poison.decode!(cpu_usage) 
      |> Enum.map(&CpuLoad.from_raw(&1))
      |> Enum.sort(fn (a, b) -> a.cpu < b.cpu end)

    %Monitor{
      cpu_usage: usage,
      cpu_users: Poison.decode!(cpu_users),
      mem_usage: Poison.decode!(mem_usage),
      hostname: hostname,
      uptime: uptime
    }
  end

  @doc """
    Return the state on :get
  """

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(_, _from, state) do
    {:reply, {:error, "Unrecognized instruction" }, state}
  end

  def handle_cast({:add_target, target}, state) do
    {:noreply, [target | state]}
  end

  def handle_cast({:remove_target, remove_target}, state) do
    targets = state |> Enum.filter(fn target -> 
      target != remove_target 
    end) 
    {:noreply, targets }
  end

  defp schedule_next_update() do
    Process.send_after(self(), :update, 0)
  end

end