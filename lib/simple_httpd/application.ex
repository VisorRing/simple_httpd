defmodule SimpleHttpd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, [app: app]) do
    # Applicationの環境からサーバオプションを取り出す
    port = Application.get_env(app, :port, 80)
    sslport = Application.get_env(app, :sslport, 443)
    keyfile = Application.get_env(app, :keyfile) |> Path.expand(System.cwd())
    certfile = Application.get_env(app, :certfile) |> Path.expand(System.cwd())

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: SimpleHttpd.Worker.start_link(arg)
      # {SimpleHttpd.Worker, arg},
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: {SimpleHttpd.PlugTop, [app: app]},
        options: [port: port]
      ),
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :https,
        plug: {SimpleHttpd.PlugTop, [app: app]},
        options: [port: sslport, keyfile: keyfile, certfile: certfile, otp_app: app]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimpleHttpd.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
