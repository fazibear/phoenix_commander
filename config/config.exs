# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :phoenix_commander, PhoenixCommanderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gVSN/o04YQwkADABpKfReuAltCPQnfbcsl7ThKkPzc1Q7T8eYOSn6tZcbYLZ1Tf/",
  render_errors: [view: PhoenixCommanderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixCommander.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "SECRET_SALT"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix_commander,
  run_browser: if System.get_env("DESKTOP"), do: true, else: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
