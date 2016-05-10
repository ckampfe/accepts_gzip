defmodule AcceptsGzip.Mixfile do
  use Mix.Project

  def project do
    [app: :accepts_gzip,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:plug, "~> 1.1"},
     {:cowboy, "~> 1.0"}]
  end
end
