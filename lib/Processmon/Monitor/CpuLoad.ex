defmodule Processmon.Monitor.CpuLoad do
  
  @derive [Poison.Encoder]
  @derive [Poison.Decoder]

  alias __MODULE__, as: CpuLoad

  defstruct [cpu: "",
    usr: "",
    sys: "",
    steal: "",
    soft: "",
    nice: "",
    irq: "",
    iowait: "",
    guest: "",
    gnice: "",
    idle: ""]

    def from_raw(raw) do
      %CpuLoad{
        cpu: raw |> Map.get("CPU"),
        usr: raw |> Map.get("%usr"),
        sys: raw |> Map.get("%sys"),
        steal: raw |> Map.get("%steal"),
        soft: raw |> Map.get("%soft"),
        nice: raw |> Map.get("%nice"),
        irq: raw |> Map.get("%irq"),
        iowait: raw |> Map.get("%iowait"),
        guest: raw |> Map.get("%guest"),
        gnice: raw |> Map.get("%gnice"),
        idle: raw |> Map.get("%idle")
      }
    end
end

