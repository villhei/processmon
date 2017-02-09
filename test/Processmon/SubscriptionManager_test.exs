defmodule Processmon.SubscriptionManager.Test do
  use ExUnit.Case

  alias Processmon.SubscriptionManager

  defp handle_receive() do
    receive do
      something -> something
    end
  end

  defp spawn_proxy(target) do
    receive_once = fn -> 
      result = receive do
        something -> send(target, something)
      after
        1 -> send(target, :timeout)
      end
      result
    end
    spawn(receive_once)
  end

  test "Should pass subscriptions to the PID registered as __MODULE__" do
    pid = self()
    Process.register(pid, Processmon.SubscriptionManager)
    SubscriptionManager.subscribe(pid)

    result = receive do 
      something -> something
    after
      1 -> :timeout
    end
    assert(result == {:"$gen_cast", {:subscribe, pid}})
  end

  test "Should pass unsubscriptions to the PID registered as __MODULE__" do
    pid = self()
    Process.register(pid, Processmon.SubscriptionManager)
    SubscriptionManager.unsubscribe(pid)

    result = receive do 
      something -> something
    after
      1 -> :timeout
    end
    assert(result == {:"$gen_cast", {:unsubscribe, pid}})
  end

  test "Should broadcast messages to all subscribers" do
    {:ok, _} = SubscriptionManager.start_link()

    first = spawn_proxy(self())
    second = spawn_proxy(self())

    SubscriptionManager.subscribe(first)
    SubscriptionManager.subscribe(second)
    SubscriptionManager.update(:foo)
    result = [handle_receive(), handle_receive()]

    assert([{:update, :foo}, {:update, :foo}] = result)
  end

  test "Should ignore the unsubscribed subscriber" do
    {:ok, _} = SubscriptionManager.start_link()

    first = spawn_proxy(self())
    second = spawn_proxy(self())

    SubscriptionManager.subscribe(first)
    SubscriptionManager.subscribe(second)
    SubscriptionManager.unsubscribe(first)
    SubscriptionManager.update(:foo)
    result = [handle_receive(), handle_receive()]

    assert([{:update, :foo}, :timeout] = result)
  end

end
