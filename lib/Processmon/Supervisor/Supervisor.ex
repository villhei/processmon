defmodule Processmon.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Processmon.Monitor, [Processmon.Monitor]),
      worker(Processmon.SubscriptionManager, [Processmon.SubscriptionManager]),
      worker(Processmon.HTTP, [Processmon.HTTP])
    ]
    supervise(children, strategy: :one_for_one)
  end
end