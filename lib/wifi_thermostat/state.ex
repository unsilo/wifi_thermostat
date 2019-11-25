defmodule WifiThermostat.State do
  defmodule Data do
    defstruct nests: %{}, using_mock: false
  end

  use GenServer
  require Logger

  alias WifiThermostat.Thermostat
  alias WifiThermostat.MockThermostat

  @interval :timer.minutes(1)

  def start_link(_vars) do
    GenServer.start_link(__MODULE__, %Data{}, name: __MODULE__)
  end

  def get_thermostats(api_key) do
    GenServer.call(__MODULE__, {:get_thermostats, api_key})
  end

  def track_thermostats(:nest, api_key) do
    GenServer.call(__MODULE__, {:track_thermostats, :nest, api_key}, 90_000)
  end

  def init(state) do
    confs = Application.get_env(:wifi_thermostat, WifiThermostat, [])
    |> IO.inspect(label: "confs")
    api_key = Keyword.get(confs, :api_key)
    using_mock = Keyword.get(confs, :use_mock_data, false)

    state = %{state | using_mock: using_mock}
    state = start_tracking(api_key, state)

    Process.send_after(self(), :tick, @interval)
    {:ok, state}
  end

  def handle_call({:track_thermostats, :nest, api_key}, _from, state) do
    {:reply, [], start_tracking(api_key, state)}
  end

  def handle_call({:get_thermostats, api_key}, _from, %{nests: nests} = state) do
    {:reply, Map.get(nests, api_key, nil), state}
  end

  def handle_info(:tick, %{nests: nests} = state) do
    new_nests =
      nests
      |> Enum.map(&check_updates(&1, state))
      |> Enum.into(%{})

    Process.send_after(self(), :tick, @interval)
    {:noreply, %{state | nests: new_nests}}
  end

  def handle_info({:broadcast, api_key}, state) do
    Registry.dispatch(WifiThermostat, api_key, fn entries ->
      for {pid, _} <- entries do
        Logger.debug("Broadcasting to pid #{inspect pid}")
        Process.send(pid, :nest_updated, [])
      end
    end)

    {:noreply, state}
  end

  def handle_info(an, state) do
    IO.inspect(an, label: "the unknown handle info")
    {:noreply, state}
  end

  defp check_updates({api_key, thermostats}, %{using_mock: true}) do
    Process.send(self(), {:broadcast, api_key}, [])
    {api_key, Enum.map(thermostats, &MockThermostat.vary_temp(&1))}
  end

  defp check_updates({api_key, _thermostats}, _state) do
    Process.send(self(), {:broadcast, api_key}, [])
    {api_key, Thermostat.get_nests(api_key)}
  end

  defp start_tracking(nil, state), do: state

  defp start_tracking(api_key, %{nests: nests, using_mock: true} = state) do
    nests = Map.put(nests, api_key, [
      MockThermostat.generate_random("M Bedroom", "cool"),
      MockThermostat.generate_random("M Den", "heat"),
      MockThermostat.generate_random("M Kitchen", "heat")
    ])
    %{state | nests: nests}
  end

  defp start_tracking(api_key, %{nests: nests} = state) do
    nests = Map.put(nests, api_key, Thermostat.get_nests(api_key))
    %{state | nests: nests}
  end
end



