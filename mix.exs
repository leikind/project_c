defmodule ProjectC.MixProject do
  use Mix.Project

  def project do
    [
      app: :project_c,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.1.0", only: :dev},
      {:pbkdf2, "~> 2.0"}
    ]
  end
end
