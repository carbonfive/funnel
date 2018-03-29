defmodule Funnel.Investigator.Strategy.SquashTest do
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
      use_cassette "squash_bad_pull_request_synced" do
        Funnel.Investigator.Strategy.Squash.investigate_push build(:squash_bad_scent), @tenta_client
        assert called Tentacat.Repositories.Statuses.create(
          build(:squash_bad_scent).owner_login,
          build(:squash_bad_scent).repo_name,
          build(:squash_bad_scent).commit_sha,
          build(:pending_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          build(:squash_bad_scent).owner_login,
          build(:squash_bad_scent).repo_name,
          build(:squash_bad_scent).commit_sha,
          build(:success_status),
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          build(:squash_bad_scent).owner_login,
          build(:squash_bad_scent).repo_name,
          build(:squash_bad_scent).commit_sha,
          Funnel.Investigator.Status.failure("Branch must be squashed"),
          :_
        )
      end
    end
  end

  test "good pull request synced" do
    with_mocks([
      {Tentacat.Repositories.Statuses, [:passthrough], []}
    ]) do
      use_cassette "squash_good_pull_request_synced" do
        Funnel.Investigator.Strategy.Squash.investigate_push build(:squash_good_scent), @tenta_client
        assert called Tentacat.Repositories.Statuses.create(
          build(:squash_good_scent).owner_login,
          build(:squash_good_scent).repo_name,
          build(:squash_good_scent).commit_sha,
          build(:pending_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          build(:squash_good_scent).owner_login,
          build(:squash_good_scent).repo_name,
          build(:squash_good_scent).commit_sha,
          Funnel.Investigator.Status.failure("Branch must be squashed"),
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          build(:squash_good_scent).owner_login,
          build(:squash_good_scent).repo_name,
          build(:squash_good_scent).commit_sha,
          build(:success_status),
          :_
        )
      end
    end
  end

end
