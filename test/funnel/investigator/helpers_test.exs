defmodule Funnel.Investigator.HelpersTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Funnel.Factory
  import Mock

  @tenta_client Tentacat.Client.new()

  setup_all do
    HTTPoison.start
  end

  test "branch pushed fails associated pull requests statuses" do
    with_mocks([
      {Tentacat.Repositories.Statuses, [:passthrough], []}
    ]) do
      use_cassette "default_branch_pushed" do
        Funnel.Investigator.Helpers.fail_open_pull_requests build(:push_scent), @tenta_client

        refute called Tentacat.Repositories.Statuses.create(
          build(:push_scent).owner_login,
          build(:push_scent).repo_name,
          build(:push_scent).commit_sha,
          :_,
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          build(:push_scent).owner_login,
          build(:push_scent).repo_name,
          :_,
          build(:failure_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          build(:push_scent).owner_login,
          build(:push_scent).repo_name,
          :_,
          build(:success_status),
          :_
        )
      end
    end
  end

end
