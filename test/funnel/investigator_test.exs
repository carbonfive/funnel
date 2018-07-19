defmodule Funnel.InvestigatorTest do
  use ExUnit.Case, async: false
  use Funnel.DataCase
  alias Funnel.{Git, GitHub}
  alias Funnel.Investigator
  import Funnel.Factory
  import Mock

  describe "when there's a sawtooth strategy repository" do
    setup_with_mocks(mocks()) do
      push_scent = build(:good_push_scent)

      {:ok, strategy} =
        Git.create_strategy(%{
          name: "sawtooth"
        })

      {:ok, repository} =
        GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          git_hub_installation_id: push_scent.installation_id,
          strategy_id: strategy.id
        })

      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "calls sawtooth investigate when action is notable", ctx do
      Investigator.investigate(ctx.push_scent)
      assert called(Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Helpers.fail_open_pull_requests(:_, ctx.push_scent, :_))
    end
  end

  describe "when there's a squash strategy repository" do
    setup_with_mocks(mocks()) do
      push_scent = build(:good_push_scent)

      {:ok, strategy} =
        Git.create_strategy(%{
          name: "squash"
        })

      {:ok, repository} =
        GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          git_hub_installation_id: push_scent.installation_id,
          strategy_id: strategy.id
        })

      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "calls squash investigate when action is notable", ctx do
      Investigator.investigate(ctx.push_scent)
      assert called(Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Helpers.fail_open_pull_requests(:_, ctx.push_scent, :_))
    end
  end

  describe "when action is notable and there's no record for repository" do
    setup_with_mocks([
      {
        Tentacat.Repositories.Statuses,
        [],
        [
          create: fn _, _, _, _, _ -> :ok end
        ]
      }
      | mocks()
    ]) do
      push_scent = build(:good_push_scent)
      {:ok, %{push_scent: push_scent}}
    end

    test "sends pending status", ctx do
      Investigator.investigate(ctx.push_scent)

      assert called(
               Tentacat.Repositories.Statuses.create(
                 :_,
                 :_,
                 :_,
                 Investigator.Status.pending_strategy(
                   FunnelWeb.Router.Helpers.repositories_url(FunnelWeb.Endpoint, :index)
                 ),
                 :_
               )
             )

      refute called(Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Helpers.fail_open_pull_requests(:_, ctx.push_scent, :_))
    end
  end

  describe "when action is notable and there's no strategy preference stored for repository" do
    setup_with_mocks([
      {
        Tentacat.Repositories.Statuses,
        [],
        [
          create: fn _, _, _, _, _ -> :ok end
        ]
      }
      | mocks()
    ]) do
      push_scent = build(:good_push_scent)

      {:ok, repository} =
        GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          git_hub_installation_id: push_scent.installation_id
        })

      {:ok, %{push_scent: push_scent, repository: repository}}
    end

    test "sends pending status", ctx do
      Investigator.investigate(ctx.push_scent)

      assert called(
               Tentacat.Repositories.Statuses.create(
                 :_,
                 :_,
                 :_,
                 Investigator.Status.pending_strategy(
                   FunnelWeb.Router.Helpers.repositories_url(
                     FunnelWeb.Endpoint,
                     :edit,
                     ctx.repository.id
                   )
                 ),
                 :_
               )
             )

      refute called(Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Helpers.fail_open_pull_requests(:_, ctx.push_scent, :_))
    end
  end

  describe "when action is notable and a rebase strategy repository" do
    setup_with_mocks(mocks()) do
      push_scent = build(:good_push_scent)

      {:ok, strategy} =
        Git.create_strategy(%{
          name: "rebase"
        })

      {:ok, repository} =
        GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          git_hub_installation_id: push_scent.installation_id,
          strategy_id: strategy.id
        })

      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "calls rebase investigate ", ctx do
      Investigator.investigate(ctx.push_scent)
      assert called(Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Helpers.fail_open_pull_requests(:_, ctx.push_scent, :_))
    end
  end

  describe "when the action is not notable and there is no repository record" do
    setup_with_mocks(mocks(false)) do
      push_scent = build(:push_scent)
      {:ok, %{push_scent: push_scent}}
    end

    test "it does nothing", ctx do
      res = Investigator.investigate(ctx.push_scent)
      assert res == :noop
      refute called(Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Helpers.fail_open_pull_requests(:_, ctx.push_scent, :_))
    end
  end

  describe "when the action is not notable and there is a repository strategy" do
    setup_with_mocks(mocks(false)) do
      push_scent = build(:bad_push_scent)
      {:ok, strategy} = Git.create_strategy(%{name: "rebase"})

      {:ok, repository} =
        GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          git_hub_installation_id: push_scent.installation_id,
          strategy_id: strategy.id
        })

      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "it calls strategy's investigate push", ctx do
      _ = Investigator.investigate(ctx.push_scent)
      refute called(Investigator.Strategy.Sawtooth.investigate_push(ctx.push_scent, :_))
      assert called(Investigator.Strategy.Rebase.investigate_push(ctx.push_scent, :_))
      refute called(Investigator.Strategy.Squash.investigate_push(ctx.push_scent, :_))
    end
  end

  describe "investigate_repository" do
    setup_with_mocks(mocks(false)) do
      push_scent = build(:pr_scent)
      {:ok, strategy} = Git.create_strategy(%{name: "rebase"})

      {:ok, repository} =
        GitHub.create_repository(%{
          git_hub_id: push_scent.repo_id,
          git_hub_installation_id: push_scent.installation_id,
          strategy_id: strategy.id
        })

      {:ok, %{push_scent: push_scent, strategy: strategy, repository: repository}}
    end

    test "does the thing", ctx do
      Investigator.investigate_repository(ctx.repository)
      assert called(Investigator.Helpers.get_scents_for_repository(ctx.repository))

      assert called(
               Investigator.Strategy.Rebase.investigate_push(
                 build(:pr_scent, %{commit_sha: "sha2"}),
                 :_
               )
             )

      assert called(
               Investigator.Strategy.Rebase.investigate_push(
                 build(:pr_scent, %{commit_sha: "sha1"}),
                 :_
               )
             )
    end
  end

  # helper for test setup
  def mocks(is_notable \\ true) do
    [
      {Funnel.GitHubAuth, [],
       [
         get_installation_client: fn _ -> Tentacat.Client.new() end
       ]},
      {Investigator.Helpers, [:passthrough],
       [
         fail_open_pull_requests: fn _, _, _ -> :ok end,
         is_notable_action?: fn _ -> is_notable end,
         get_scents_for_repository: fn _ ->
           [
             build(:pr_scent, %{commit_sha: "sha1"}),
             build(:pr_scent, %{commit_sha: "sha2"})
           ]
         end
       ]},
      {Investigator.Strategy.Sawtooth, [], [investigate_push: fn _, _ -> :ok end]},
      {Investigator.Strategy.Squash, [], [investigate_push: fn _, _ -> :ok end]},
      {Investigator.Strategy.Rebase, [], [investigate_push: fn _, _ -> :ok end]}
    ]
  end
end
