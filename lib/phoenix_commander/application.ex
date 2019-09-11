defmodule PhoenixCommander.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixCommander.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhoenixCommanderWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  if Application.get_env(:phoenix_commander, :run_browser) do
    def children do
      [
        PhoenixCommanderWeb.Endpoint,
        PhoenixCommander.Browser
      ]
    end
  else
    def children do
      [
        PhoenixCommanderWeb.Endpoint
      ]
    end
  end
end
