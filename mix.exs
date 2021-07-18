defmodule PermastateOperator.MixProject do
  use Mix.Project

  def project do
    [
      app: :permastate_operator,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bonny, "~> 0.4"},
      {:grpc, "~> 0.3"},
      {:protobuf, "~> 0.8.0-beta.1", override: true},
      {:cowlib, "~> 2.11.0", override: true},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
