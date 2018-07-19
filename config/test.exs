use Mix.Config

config :exvcr,
  vcr_cassette_library_dir: "test/fixture/vcr_cassettes",
  custom_cassette_library_dir: "test/fixture/custom_cassettes",
  filter_sensitive_data: [],
  filter_url_params: false,
  filter_request_headers: ["Authorization"],
  response_headers_blacklist: ["Authorization"]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :funnel, FunnelWeb.Endpoint,
  http: [port: 4001],
  server: false

config :funnel, github_app_id: 6615

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :funnel, Funnel.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "funnel_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
