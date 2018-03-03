defmodule Funnel.Investigator.HelpersTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Funnel.Factory
  import Mock

  @tenta_client Tentacat.Client.new()

  setup_all do
    HTTPoison.start
  end

  test "fail_open_pull_requests/2 fails all associated open pull requests" do
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

  test "mark_commit_pending/2 sends a single pending status" do
    with_mocks([
      {Tentacat.Repositories.Statuses, [:passthrough], []}
    ]) do
      use_cassette "mark_commit_pending" do
        Funnel.Investigator.Helpers.mark_commit_pending build(:push_scent), @tenta_client

        assert called Tentacat.Repositories.Statuses.create(
          build(:push_scent).owner_login,
          build(:push_scent).repo_name,
          build(:push_scent).commit_sha,
          build(:pending_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
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

  test "get_base_sha/2 returns a sha" do
    use_cassette "default_branch_pushed" do
      res = Funnel.Investigator.Helpers.get_base_sha build(:push_scent), @tenta_client

      assert is_binary(res)
      refute is_list(res)
    end
  end

end
