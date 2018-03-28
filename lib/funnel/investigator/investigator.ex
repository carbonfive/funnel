defmodule Funnel.Investigator do
  alias Funnel.GitHubAuth
  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Strategy

  @doc """
  Handle a given a webhook notification and generate github statuses
  """
  @spec investigate(%Funnel.Scent{}) :: any
  def investigate(scent) do
    tenta_client = GitHubAuth.get_installation_client(scent.installation_id)
    cond do
      Helpers.is_notable_action?(scent) ->
        Strategy.Sawtooth.investigate_push(scent, tenta_client)
      # if its not a notable action, then its a push event
      true ->
        Helpers.fail_open_pull_requests(scent, tenta_client)
    end
  end

end
