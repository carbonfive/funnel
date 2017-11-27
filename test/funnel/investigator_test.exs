defmodule Funnel.InvestigatorTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Funnel.Factory
  import Mock

  setup_all do
    HTTPoison.start
  end

  test "bad non default branch pushed" do
    with_mocks([
      {Tentacat.Client, [:passthrough], []},
      {Tentacat.Repositories.Statuses, [:passthrough], []},
      {Tentacat.Commits, [:passthrough], []},
      {Tentacat.Repositories.Branches, [:passthrough], []},
      {Funnel.GitHubAuth, [], [get_installation_client: fn(_) -> Tentacat.Client.new() end]}
    ]) do
      use_cassette "bad_non_default_branch_pushed" do
        Funnel.Investigator.investigate build(:bad_push_scent)
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          build(:bad_push_scent).commit_sha,
          build(:pending_status),
          :_
        )
        assert called Tentacat.Repositories.Branches.find(
          "outofambit",
          "musical-spork",
          "master",
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          build(:bad_push_scent).commit_sha,
          build(:failure_status),
          :_
        )
      end
    end
  end

  test "good non default branch pushed" do
    with_mocks([
      {Tentacat.Client, [:passthrough], []},
      {Tentacat.Repositories.Statuses, [:passthrough], []},
      {Tentacat.Commits, [:passthrough], []},
      {Tentacat.Repositories.Branches, [:passthrough], []},
      {Funnel.GitHubAuth, [], [get_installation_client: fn(_) -> Tentacat.Client.new() end]}
    ]) do
      use_cassette "good_non_default_branch_pushed" do
        Funnel.Investigator.investigate build(:good_push_scent)
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          build(:good_push_scent).commit_sha,
          build(:pending_status),
          :_
        )
        assert called Tentacat.Repositories.Branches.find(
          "outofambit",
          "musical-spork",
          "master",
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          build(:good_push_scent).commit_sha,
          build(:success_status),
          :_
        )
      end
    end
  end

  test "default branch pushed" do
    with_mocks([
      {Tentacat.Client, [:passthrough], []},
      {Tentacat.Repositories.Statuses, [:passthrough], []},
      {Tentacat.Commits, [:passthrough], []},
      {Tentacat.Repositories.Branches, [:passthrough], []},
      {Funnel.GitHubAuth, [], [get_installation_client: fn(_) -> Tentacat.Client.new() end]}
    ]) do
      use_cassette "default_branch_pushed" do
        Task.async(fn -> Funnel.Investigator.investigate build(:default_push_scent) end)
        |> Task.await(10000)

        refute called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          build(:default_push_scent).commit_sha,
          :_,
          :_
        )
        assert called Tentacat.Repositories.Branches.list(
          "outofambit",
          "musical-spork",
          :_
        )
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          :_,
          build(:failure_status),
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          :_,
          build(:success_status),
          :_
        )
      end
    end
  end

end
