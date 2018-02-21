defmodule Funnel.Investigator.Strategy.RebaseTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Funnel.Factory
  import Mock

  @tenta_client Tentacat.Client.new()

  setup_all do
    HTTPoison.start
  end

  test "bad pull request synced" do
    with_mocks([
      {Tentacat.Repositories.Statuses, [:passthrough], []}
    ]) do
      use_cassette "rebase_bad_pull_request_synced" do
        Funnel.Investigator.Strategy.Rebase.investigate_push build(:rebase_bad_scent), @tenta_client
        assert called Tentacat.Repositories.Statuses.create(
          build(:rebase_bad_scent).owner_login,
          build(:rebase_bad_scent).repo_name,
          build(:rebase_bad_scent).commit_sha,
          build(:pending_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          build(:rebase_bad_scent).owner_login,
          build(:rebase_bad_scent).repo_name,
          build(:rebase_bad_scent).commit_sha,
          build(:success_status),
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          build(:rebase_bad_scent).owner_login,
          build(:rebase_bad_scent).repo_name,
          build(:rebase_bad_scent).commit_sha,
          build(:failure_status),
          :_
        )
      end
    end
  end

  test "good pull request synced" do
    with_mocks([
      {Tentacat.Repositories.Statuses, [:passthrough], []}
    ]) do
      use_cassette "rebase_good_pull_request_synced" do
        Funnel.Investigator.Strategy.Rebase.investigate_push build(:rebase_good_scent), @tenta_client
        assert called Tentacat.Repositories.Statuses.create(
          build(:rebase_good_scent).owner_login,
          build(:rebase_good_scent).repo_name,
          build(:rebase_good_scent).commit_sha,
          build(:pending_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          build(:rebase_good_scent).owner_login,
          build(:rebase_good_scent).repo_name,
          build(:rebase_good_scent).commit_sha,
          build(:failure_status),
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          build(:rebase_good_scent).owner_login,
          build(:rebase_good_scent).repo_name,
          build(:rebase_good_scent).commit_sha,
          build(:success_status),
          :_
        )
      end
    end
  end

end
