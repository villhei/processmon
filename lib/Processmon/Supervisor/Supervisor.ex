defmodule Processmon.Supervisor do
  use Supervisor

  def start_link(enable_http? \\ true) do
    Supervisor.start_link(__MODULE__, enable_http?)
  end

  def init(enable_http?) do
    children = [
      worker(Processmon.Monitor, [Processmon.Monitor]),
      worker(Processmon.ReportCollector, []),
      worker(Processmon.SubscriptionManager, []),
    ]
    children = case enable_http? do
      true -> children ++ [worker(Processmon.HTTP, [Processmon.HTTP])]
      false -> children
    end
    supervise(children, strategy: :one_for_one)
  end
end