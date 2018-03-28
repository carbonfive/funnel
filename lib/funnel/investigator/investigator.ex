defmodule Funnel.Investigator do
  alias Funnel.Repo
  alias Funnel.GitHubAuth
  alias Funnel.GitHub
  alias Funnel.Investigator.Helpers

  @doc """
  Handle a given a webhook notification and generate github statuses
  """
  @spec investigate(%Funnel.Scent{}) :: any
  def investigate(scent) do
    tenta_client = GitHubAuth.get_installation_client(scent.installation_id)
    if Helpers.is_notable_action?(scent),
      do: apply(strategy_module(scent), :investigate_push, [scent, tenta_client]),
      else: Helpers.fail_open_pull_requests(scent, tenta_client)
  end

  @spec strategy_module(%Funnel.Scent{}) :: atom
  defp strategy_module(scent) do
    repository = Repo.get_by!(GitHub.Repository, git_hub_id: scent.repo_id)
    repository = Repo.preload(repository, :strategy)
    String.to_existing_atom("#{__MODULE__}.Strategy.#{String.capitalize(repository.strategy.name)}")
  end

end
