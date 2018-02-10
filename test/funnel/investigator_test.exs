defmodule Funnel.InvestigatorTest do
  use ExUnit.Case, async: false
  alias Funnel.Investigator
  import Funnel.Factory
  import Mock

  test "calls sawtooth investigate when action is notable" do
    with_mocks([
      {Funnel.GitHubAuth, [],
        [
          get_installation_client: fn(_) -> Tentacat.Client.new() end
        ]},
      {Investigator.Helpers, [:passthrough],
        [
          fail_open_pull_requests: fn(_, _) -> :noop end,
          is_notable_action?: fn(_) -> true end
        ]
      },
      {Investigator.Strategy.Sawtooth, [], [investigate_push: fn(_, _) -> :noop end]}
    ]) do
      Investigator.investigate(build(:push_scent))
      assert called Investigator.Strategy.Sawtooth.investigate_push(build(:push_scent), :_)
      refute called Investigator.Helpers.fail_open_pull_requests(build(:push_scent), :_)
    end
  end

  test "fails pull requests when action is not notable" do
    with_mocks([
      {Funnel.GitHubAuth, [],
        [
          get_installation_client: fn(_) -> Tentacat.Client.new() end
        ]},
      {Investigator.Helpers, [:passthrough],
        [
          fail_open_pull_requests: fn(_, _) -> :noop end,
          is_notable_action?: fn(_) -> false end
        ]
      },
      {Investigator.Strategy.Sawtooth, [], [investigate_push: fn(_, _) -> :noop end]}
    ]) do
      Investigator.investigate(build(:push_scent))
      refute called Investigator.Strategy.Sawtooth.investigate_push(build(:push_scent), :_)
      assert called Investigator.Helpers.fail_open_pull_requests(build(:push_scent), :_)
    end
  end

end
