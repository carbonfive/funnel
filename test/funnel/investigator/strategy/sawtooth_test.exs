defmodule Funnel.Investigator.Strategy.SawtoothTest do
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
      use_cassette "bad_pull_request_synced" do
        Funnel.Investigator.Strategy.Sawtooth.investigate_push build(:bad_push_scent), @tenta_client
        assert called Tentacat.Repositories.Statuses.create(
          :_,
          build(:bad_push_scent).owner_login,
          build(:bad_push_scent).repo_name,
          build(:bad_push_scent).commit_sha,
          build(:pending_status)
        )
        refute called Tentacat.Repositories.Statuses.create(
          :_,
          build(:bad_push_scent).owner_login,
          build(:bad_push_scent).repo_name,
          build(:bad_push_scent).commit_sha,
          build(:success_status)
        )
        assert called Tentacat.Repositories.Statuses.create(
          :_,
          build(:bad_push_scent).owner_login,
          build(:bad_push_scent).repo_name,
          build(:bad_push_scent).commit_sha,
          Funnel.Investigator.Status.failure("Branch must be rebased and squashed")
        )
      end
    end
  end

  test "good pull request synced" do
    with_mocks([
      {Tentacat.Repositories.Statuses, [:passthrough], []}
    ]) do
      use_cassette "good_pull_request_synced" do
        Funnel.Investigator.Strategy.Sawtooth.investigate_push build(:good_push_scent), @tenta_client
        assert called Tentacat.Repositories.Statuses.create(
          :_,
          build(:good_push_scent).owner_login,
          build(:good_push_scent).repo_name,
          build(:good_push_scent).commit_sha,
          build(:pending_status)
        )
        refute called Tentacat.Repositories.Statuses.create(
          :_,
          build(:good_push_scent).owner_login,
          build(:good_push_scent).repo_name,
          build(:good_push_scent).commit_sha,
          Funnel.Investigator.Status.failure("Branch must be rebased and squashed")
        )
        assert called Tentacat.Repositories.Statuses.create(
          :_,
          build(:good_push_scent).owner_login,
          build(:good_push_scent).repo_name,
          build(:good_push_scent).commit_sha,
          build(:success_status)
        )
      end
    end
  end

end
