defmodule WifiThermostat.Application do
  @moduledoc false

  use Application

  alias WifiThermostat.State

  def start(_type, _args) do
    children = [
      {Registry, keys: :duplicate, name: WifiThermostat},
      State
    ]

    opts = [strategy: :one_for_one, name: WifiThermostat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
