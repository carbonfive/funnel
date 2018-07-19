defmodule Funnel.PlatterTest do
  use ExUnit.Case, async: false
  use Funnel.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias Funnel.Platter
  import Mock

  @tenta_client Tentacat.Client.new()

  setup_all do
    HTTPoison.start()
  end

  setup_with_mocks([
    {Funnel.GitHubAuth, [],
     [
       get_user_client: fn _ -> @tenta_client end
     ]}
  ]) do
    :ok
  end

  test "get_user_installations/1" do
    use_cassette "list_installations_for_user" do
      assert Enum.count(Platter.get_user_installations("t0k3nstr1ng")) === 1
    end
  end

  test "get_user_repositories_for_installation/2" do
    use_cassette "list_installation_repositories_for_user" do
      assert Enum.count(Platter.get_user_repositories_for_installation(66216, "t0k3nstr1ng")) ===
               2
    end
  end

  test "get_all_user_repositories/1" do
    use_cassette "get_all_user_repositories" do
      assert Enum.count(Platter.get_all_user_repositories("t0k3nstr1ng")) === 2
    end
  end
end
