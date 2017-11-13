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
      {Funnel.Auth, [], [get_jwt: fn() -> "your.jwt.here" end]}
    ]) do
      use_cassette "bad_non_default_branch_pushed" do
        Funnel.Investigator.investigate build(:push_webhook_bad_body)
        assert called Tentacat.Client.new :_
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          "6e669ab91b9cec1ff8bfcdd00dc18a87733269b1",
          %{
             "state": "pending",
             "description": "Investigating your commit",
             "context": "funnel"
          },
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
          "6e669ab91b9cec1ff8bfcdd00dc18a87733269b1",
          %{
             "state": "failure",
             "description": "Commit must be rebased and squashed",
             "context": "funnel"
          },
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
      {Funnel.Auth, [], [get_jwt: fn() -> "your.jwt.here" end]}
    ]) do
      use_cassette "good_non_default_branch_pushed" do
        Funnel.Investigator.investigate build(:push_webhook_good_body)
        assert called Tentacat.Client.new :_
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          build(:push_webhook_good_body)["after"],
          %{
             "state": "pending",
             "description": "Investigating your commit",
             "context": "funnel"
          },
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
          build(:push_webhook_good_body)["after"],
          %{
             "state": "success",
             "description": "Commit is good to merge",
             "context": "funnel"
          },
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
      {Funnel.Auth, [], [get_jwt: fn() -> "your.jwt.here" end]}
    ]) do
      use_cassette "default_branch_pushed" do
        Task.async(fn -> Funnel.Investigator.investigate build(:push_webhook_master_body) end)
        |> Task.await(10000)

        assert called Tentacat.Client.new :_
        refute called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          "966bf60dcd5b7eb57997ae88ef2e46f6549a9c8a",
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
          %{
             "state": "failure",
             "description": "Commit must be rebased and squashed",
             "context": "funnel"
           },
          :_
        )
        refute called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          :_,
          %{
             "state": "success",
             "description": "Commit is good to merge",
             "context": "funnel"
          },
          :_
        )
      end
    end
  end

end
