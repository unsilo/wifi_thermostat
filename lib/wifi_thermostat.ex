defmodule WifiThermostat do
  @moduledoc """
  Documentation for WifiThermostat.
  """

  require Logger

  alias WifiThermostat.State

  def get_thermostats(api_key \\ nil) do
    State.get_thermostats(api_key)
  end

  def thermostat_subscribe(api_key) do
    Registry.register(WifiThermostat, api_key, [])
    if is_nil(State.get_thermostats(api_key)) do
      State.track_thermostats(:nest, api_key)
      Logger.info("new subscription")
    else
      Logger.info("duplicate subscription")
    end
  end

  def set_target_temperature(uuid, api_key, target_temperature_f) do
    WifiThermostat.Thermostat.set_target_temperature(uuid, api_key, target_temperature_f)
  end
end
