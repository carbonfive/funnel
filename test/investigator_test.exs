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
      {Tentacat.Repositories.Branches, [:passthrough], []}
    ]) do
      use_cassette "bad_non_default_branch_pushed" do
        Funnel.Investigator.investigate build(:push_webhook_bad_body)
        assert called Tentacat.Client.new :_
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          "1b076d5669d301aeff2cd6e64f16c433598b99a4",
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
          "1b076d5669d301aeff2cd6e64f16c433598b99a4",
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
      {Tentacat.Repositories.Branches, [:passthrough], []}
    ]) do
      use_cassette "good_non_default_branch_pushed" do
        Funnel.Investigator.investigate build(:push_webhook_good_body)
        assert called Tentacat.Client.new :_
        assert called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          "986af48c0c24152831fc964f52dcbf90e70e8f6e",
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
          "986af48c0c24152831fc964f52dcbf90e70e8f6e",
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
      {Tentacat.Repositories.Branches, [:passthrough], []}
    ]) do
      use_cassette "default_branch_pushed" do
        Funnel.Investigator.investigate build(:push_webhook_master_body)
        assert called Tentacat.Client.new :_
        refute called Tentacat.Repositories.Statuses.create(
          "outofambit",
          "musical-spork",
          "986af48c0c24152831fc964f52dcbf90e70e8f6e",
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
