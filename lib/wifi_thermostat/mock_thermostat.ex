defmodule WifiThermostat.MockThermostat do

  alias WifiThermostat.Thermostat

  def generate_random(name, mode \\ :heat) do
    amb = Enum.random(68..74)
    targ = 72

    mode_state =
      cond do
        mode == "heat" && amb < targ ->
          "heating"

        mode == "cool" && amb > targ ->
          "cooling"

        true ->
          "off"
      end

    %Thermostat{
      ambient_temperature_f: amb,
      target_temperature_f: targ,
      can_cool: true,
      can_heat: true,
      hvac_mode: mode,
      hvac_state: mode_state,
      is_online: true,
      last_connection: DateTime.utc_now(),
      name: name
    }
  end

  def vary_temp(
        %{
          ambient_temperature_f: ambient_temperature_f,
          target_temperature_f: target_temperature_f,
          hvac_mode: hvac_mode
        } = device
      ) do
    ambient_temperature_f = ambient_temperature_f + Enum.random(-1..1)

    mode_state =
      cond do
        hvac_mode == "heat" && ambient_temperature_f < target_temperature_f ->
          "heating"

        hvac_mode == "cool" && ambient_temperature_f > target_temperature_f ->
          "cooling"

        true ->
          "off"
      end

    %Thermostat{device | ambient_temperature_f: ambient_temperature_f, hvac_state: mode_state}
  end
end
