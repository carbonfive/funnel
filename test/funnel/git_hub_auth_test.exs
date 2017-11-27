defmodule Funnel.GitHubAuthTest do
  import Funnel.GitHubAuth
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Mock

  setup_all do
    HTTPoison.start
  end

  test "get_installation_client/1" do
    with_mocks([
      {Funnel.GitHubAuth.Jwt, [], [get_jwt: fn() -> "your.jwt.here" end]}
    ]) do
      use_cassette "get_installation_access_token" do
        client = get_installation_client(65943)
        assert client.auth.access_token == "v1.6c0183e6ff458c390b80774664159c818ac32914"
      end
    end
  end

end
