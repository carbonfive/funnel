# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :funnel, github_app_id: 6544
config :funnel, notable_actions: ["opened", "reopened", "synchronize"]
config :tentacat, extra_headers: [{"Accept", "application/vnd.github.machine-man-preview+json"}]
# General application configuration
config :funnel, ecto_repos: [Funnel.Repo]

config :funnel, oauth_redirect_uri: "https://funnel.ngrok.io/auth/callback"

# Configures the endpoint
config :funnel, FunnelWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QYRH+Gbs+Qf190fcL99b4xKxTt7qiHyGQTaKNmCXsLBedu68iflOsm8s2mBSayWV",
  render_errors: [view: FunnelWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Funnel.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
