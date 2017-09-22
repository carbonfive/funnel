use Mix.Config

config :exvcr, [
  vcr_cassette_library_dir: "test/fixture/vcr_cassettes",
  custom_cassette_library_dir: "test/fixture/custom_cassettes",
  filter_sensitive_data: [],
  filter_url_params: false,
  filter_request_headers: ["Authorization"],
  response_headers_blacklist: ["Authorization"]
]
