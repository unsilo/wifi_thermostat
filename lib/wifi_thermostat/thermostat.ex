defmodule WifiThermostat.Thermostat do
  defstruct name: nil,
            device_id: nil,
            location_id: nil,
            structure_id: nil,
            ambient_temperature_f: nil,
            ambient_temperature_c: nil,
            target_temperature_f: nil,
            target_temperature_c: nil,
            time_to_target: nil,
            humidity: nil,
            can_cool: nil,
            can_heat: nil,
            has_leaf: nil,
            hvac_mode: nil,
            hvac_state: nil,
            is_online: nil,
            last_connection: nil

  alias WifiThermostat.Thermostat

  def get_nests(api_key) do

    %HTTPoison.Response{body: body} =
      HTTPoison.get!(
        "https://developer-api.nest.com",
        [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{api_key}"}
        ],
        follow_redirect: true
      )

    %{"devices" => %{"thermostats" => thermostats}} = Jason.decode!(body)

    for {_, therm} <- thermostats do
      nest_from_data(therm)
    end
  end

  def set_target_temperature(uuid, api_key, target_temperature_f) do

    HTTPoison.put!(
      "https://developer-api.nest.com/devices/thermostats/#{uuid}",
      "{\"target_temperature_f\": #{target_temperature_f}}",
      [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{api_key}"}
      ],
      follow_redirect: true
    ) |> case do
      %HTTPoison.AsyncResponse{
        id: {:maybe_redirect, _status, header, _client}
      } ->
        {"Location", new_url} = Enum.find(header, fn {k, _v} -> k == "Location" end)

        HTTPoison.put!(
          new_url,
          "{\"target_temperature_f\": #{target_temperature_f}}",
          [
            {"Content-Type", "application/json"},
            {"Authorization", "Bearer #{api_key}"}
          ],
            follow_redirect: true
          )

      %HTTPoison.Response{body: body} ->
        Jason.decode!(body)
    end
  end

  def nest_from_data(%{
        "name" => name,
        "device_id" => device_id,
        "structure_id" => structure_id,
        "ambient_temperature_f" => ambient_temperature_f,
        "ambient_temperature_c" => ambient_temperature_c,
        "target_temperature_f" => target_temperature_f,
        "target_temperature_c" => target_temperature_c,
        "humidity" => humidity,
        "can_cool" => can_cool,
        "can_heat" => can_heat,
        "has_leaf" => has_leaf,
        "hvac_mode" => hvac_mode,
        "hvac_state" => hvac_state,
        "is_online" => is_online,
        "last_connection" => last_connection
      }) do
    %Thermostat{
      name: name,
      device_id: device_id,
      structure_id: structure_id,
      ambient_temperature_f: ambient_temperature_f,
      ambient_temperature_c: ambient_temperature_c,
      target_temperature_f: target_temperature_f,
      target_temperature_c: target_temperature_c,
      humidity: humidity,
      can_cool: can_cool,
      can_heat: can_heat,
      has_leaf: has_leaf,
      hvac_mode: hvac_mode,
      hvac_state: hvac_state,
      is_online: is_online,
      last_connection: last_connection
    }
  end
end
