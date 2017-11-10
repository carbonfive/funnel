defmodule Funnel.Mixfile do
  use Mix.Project

  def project do
    [
      app: :funnel,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :tentacat, :json_web_token],
      mod: {Funnel, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"},
      # {:tentacat, "~> 0.7"},
      {:tentacat, github: "outofambit/tentacat", branch: "installation-api"},
      {:poison, "~> 3.0"},
      {:ex_machina, "~> 2.1", only: :test},
      {:mock, "~> 0.3", only: :test},
      {:exvcr, "~> 0.8", only: :test},
      {:distillery, "~> 1.5", runtime: false},
      {:json_web_token, "~> 0.2.10"}
    ]
  end

  # This makes sure your factory and any other modules in test/support are compiled when in the test environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
