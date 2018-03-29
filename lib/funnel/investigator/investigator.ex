defmodule Funnel.Investigator do
  alias Funnel.Repo
  alias Funnel.GitHubAuth
  alias Funnel.GitHub
  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Status
  alias Tentacat.Repositories
  require Logger

  @doc """
  Handle a given a webhook notification and generate github statuses
  """
  @spec investigate(%Funnel.Scent{}) :: atom
  def investigate(scent) do
    tenta_client = GitHubAuth.get_installation_client(scent.installation_id)
    Logger.debug "Investigating #{inspect(scent)}"
    cond do
      Helpers.is_notable_action?(scent) and repository_has_strategy(scent)
        -> apply(strategy_module(scent), :investigate_push, [scent, tenta_client])
      Helpers.is_notable_action?(scent)
        -> Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, Status.pending_strategy(repository_form_url(scent)), tenta_client
      repository_has_strategy(scent)
        -> Helpers.fail_open_pull_requests("This branch must updated", scent, tenta_client)
      true
        -> :noop
    end
  end

  @spec strategy_module(%Funnel.Scent{}) :: atom
  defp strategy_module(scent) do
    repository = Repo.get_by!(GitHub.Repository, git_hub_id: scent.repo_id)
    repository = Repo.preload(repository, :strategy)
    String.to_existing_atom("#{__MODULE__}.Strategy.#{String.capitalize(repository.strategy.name)}")
  end

  @spec repository_has_strategy(%Funnel.Scent{}) :: boolean
  defp repository_has_strategy(scent) do
    try do
      not is_nil(Repo.get_by!(GitHub.Repository, git_hub_id: scent.repo_id).strategy_id)
    rescue
      Ecto.NoResultsError -> false
    end
  end

  defp repository_form_url(scent) do
    alias FunnelWeb.Router.Helpers
    alias FunnelWeb.Endpoint
    case Repo.get_by(GitHub.Repository, git_hub_id: scent.repo_id) do
      nil -> Helpers.repositories_url(Endpoint, :index)
      repository -> Helpers.repositories_url(Endpoint, :edit, repository.id)
    end
  end

end
