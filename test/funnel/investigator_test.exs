defmodule Funnel.InvestigatorTest do
  use ExUnit.Case, async: false
  use Funnel.DataCase
  alias Funnel.{Git, GitHub}
  alias Funnel.Investigator
  import Funnel.Factory
  import Mock

  describe "when there's a sawtooth strategy repository" do
    setup_with_mocks(mocks()) do
      push_scent = build(:push_scent)
      {:ok, strategy} = Git.create_strategy(%{
        name: "sawtooth"
        })
      {:ok, repository} = GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          strategy_id: strategy.id
        })
      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "calls sawtooth investigate when action is notable", ctx do
      Investigator.investigate(ctx.push_scent)
      assert called Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Helpers.fail_open_pull_requests(ctx.push_scent, :_)
    end
  end

  describe "when there's a squash strategy repository" do
    setup_with_mocks(mocks()) do
      push_scent = build(:push_scent)
      {:ok, strategy} = Git.create_strategy(%{
        name: "squash"
        })
      {:ok, repository} = GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          strategy_id: strategy.id
        })
      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "calls squash investigate when action is notable", ctx do
      Investigator.investigate(ctx.push_scent)
      assert called Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Helpers.fail_open_pull_requests(ctx.push_scent, :_)
    end
  end

  describe "when there's a rebase strategy repository" do
    setup_with_mocks(mocks()) do
      push_scent = build(:push_scent)
      {:ok, strategy} = Git.create_strategy(%{
        name: "rebase"
        })
      {:ok, repository} = GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          strategy_id: strategy.id
        })
      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "calls rebase investigate when action is notable", ctx do
      Investigator.investigate(ctx.push_scent)
      assert called Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Helpers.fail_open_pull_requests(ctx.push_scent, :_)
    end
  end

  describe "when the action is not notable" do
    setup_with_mocks(mocks(false)) do
      push_scent = build(:push_scent)
      {:ok, %{push_scent: push_scent}}
    end

    test "fails related open pull requests when action is not notable", ctx do
      Investigator.investigate(build(:push_scent))
      refute called Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_)
      refute called Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_)
      assert called Investigator.Helpers.fail_open_pull_requests(ctx.push_scent, :_)
    end
  end

  # helper for test setup
  def mocks(is_notable \\ true) do
    [
      {Funnel.GitHubAuth, [],
        [
          get_installation_client: fn(_) -> Tentacat.Client.new() end
        ]},
      {Investigator.Helpers, [:passthrough],
        [
          fail_open_pull_requests: fn(_, _) -> :noop end,
          is_notable_action?: fn(_) -> is_notable end
        ]
      },
      {Investigator.Strategy.Sawtooth, [], [investigate_push: fn(_, _) -> :noop end]},
      {Investigator.Strategy.Squash, [], [investigate_push: fn(_, _) -> :noop end]},
      {Investigator.Strategy.Rebase, [], [investigate_push: fn(_, _) -> :noop end]}
    ]
  end

end
