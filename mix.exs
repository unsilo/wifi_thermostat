defmodule WifiThermostat.MixProject do
  use Mix.Project

  def project do
    [
      app: :wifi_thermostat,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {WifiThermostat.Application, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.5"}
    ]
  end
end
