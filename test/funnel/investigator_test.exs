defmodule Funnel.InvestigatorTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Funnel.Factory
  import Mock

  setup_all do
    HTTPoison.start
  end

  test "bad pull request synced" do
    with_mocks([
      {Tentacat.Client, [:passthrough], []},
      {Tentacat.Repositories.Statuses, [:passthrough], []},
      {Funnel.GitHubAuth, [], [get_installation_client: fn(_) -> Tentacat.Client.new() end]}
    ]) do
      use_cassette "bad_pull_request_synced" do
        Funnel.Investigator.investigate build(:bad_push_scent)
        assert called Tentacat.Repositories.Statuses.create(
          build(:bad_push_scent).owner_login,
          build(:bad_push_scent).repo_name,
          build(:bad_push_scent).commit_sha,
          build(:pending_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          build(:bad_push_scent).owner_login,
          build(:bad_push_scent).repo_name,
          build(:bad_push_scent).commit_sha,
          build(:success_status),
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          build(:bad_push_scent).owner_login,
          build(:bad_push_scent).repo_name,
          build(:bad_push_scent).commit_sha,
          build(:failure_status),
          :_
        )
      end
    end
  end

  test "good pull request synced" do
    with_mocks([
      {Tentacat.Client, [:passthrough], []},
      {Tentacat.Repositories.Statuses, [:passthrough], []},
      {Funnel.GitHubAuth, [], [get_installation_client: fn(_) -> Tentacat.Client.new() end]}
    ]) do
      use_cassette "good_pull_request_synced" do
        Funnel.Investigator.investigate build(:good_push_scent)
        assert called Tentacat.Repositories.Statuses.create(
          build(:good_push_scent).owner_login,
          build(:good_push_scent).repo_name,
          build(:good_push_scent).commit_sha,
          build(:pending_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          build(:good_push_scent).owner_login,
          build(:good_push_scent).repo_name,
          build(:good_push_scent).commit_sha,
          build(:failure_status),
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          build(:good_push_scent).owner_login,
          build(:good_push_scent).repo_name,
          build(:good_push_scent).commit_sha,
          build(:success_status),
          :_
        )
      end
    end
  end

  test "branch pushed" do
    with_mocks([
      {Tentacat.Client, [:passthrough], []},
      {Tentacat.Repositories.Statuses, [:passthrough], []},
      {Funnel.GitHubAuth, [], [get_installation_client: fn(_) -> Tentacat.Client.new() end]}
    ]) do
      use_cassette "default_branch_pushed" do
        Funnel.Investigator.investigate build(:push_scent)

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
