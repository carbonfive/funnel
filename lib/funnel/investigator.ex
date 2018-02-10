defmodule Funnel.Investigator do
  alias Funnel.GitHubAuth
  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Strategy

  @doc """
  Handle a given a webhook notification and generate github statuses
  """
  def investigate(scent) do
    {:ok, agent_pid} = Agent.start_link(
      fn ->
        GitHubAuth.get_installation_client(scent.installation_id)
      end
    )
    cond do
      Helpers.is_notable_action?(scent) ->
        Strategy.Sawtooth.investigate_push(scent, agent_pid)
      true ->
        Helpers.fail_open_pull_requests(scent, agent_pid)
    end
  end

end
