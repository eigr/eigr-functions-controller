defmodule Eigr.FunctionsController.MixProject do
  use Mix.Project

  @app :eigr_functions_controller

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer],
      mod: {Eigr.FunctionsController, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bonny, "~> 0.4"},
      {:protobuf, "~> 0.8.0-beta.1", override: true},
      {:grpc, github: "elixir-grpc/grpc", override: true},
      {:cowlib, "~> 2.11.0", override: true},
      {:prometheus, "~> 4.6"},
      {:grpc_prometheus, "~> 0.1"},
      {:prometheus_plugs, "~> 1.1"},
      {:plug_cowboy, "~> 2.3"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:bakeware, ">= 0.0.0", runtime: false}
    ]
  end

  defp release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie"
      # steps: [
      #  :assemble,
      #  &Bakeware.assemble/1
      # ],
      # bakeware: [compression_level: 19]
    ]
  end
end
