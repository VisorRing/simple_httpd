defmodule SimpleHttpd.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_httpd,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug],		# cowboyとplugを実行
      mod: {SimpleHttpd.Application, [app: project()[:app]]}	# SimpleHttpd.Application.start/2を起動
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:cowboy, "~> 2.4.0"},	# cowboyをHEXからダウンロード
      {:plug, "~> 1.6.2"}	# plugをHEXからダウンロード
    ]
  end
end
