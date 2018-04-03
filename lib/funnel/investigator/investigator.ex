defmodule Funnel.Investigator do
  alias Funnel.Repo
  alias Funnel.GitHubAuth
  alias Funnel.GitHub
  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Status
  alias Tentacat.Repositories

  @doc """
  Handle a given a webhook notification and generate github statuses
  """
  @spec investigate(%Funnel.Scent{}) :: atom
  def investigate(scent) do
    tenta_client = GitHubAuth.get_installation_client(scent.installation_id)
    cond do
      Helpers.is_notable_action?(scent) and repository_has_strategy(scent)
        -> apply(Helpers.strategy_module(scent), [scent, tenta_client])
      Helpers.is_notable_action?(scent)
        -> Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, Status.pending_strategy(repository_form_url(scent)), tenta_client
      repository_has_strategy(scent)
        -> apply(Helpers.strategy_module(scent), [scent, tenta_client])
      true
        -> :noop
    end
  end

  @spec investigate_repository(%Funnel.GitHub.Repository{}) :: atom
  def investigate_repository(repository) do
    Helpers.get_scents_for_repository(repository)
    |> Enum.map(fn(scent) -> investigate(scent) end)
    :ok
  end

  @spec repository_has_strategy(%Funnel.Scent{}) :: boolean
  defp repository_has_strategy(scent) do
    try do
      not is_nil(Repo.get_by!(GitHub.Repository, git_hub_id: scent.repo_id).strategy_id)
    rescue
      Ecto.NoResultsError -> false
    end
  end

  @spec repository_form_url(%Funnel.Scent{}) :: binary
  defp repository_form_url(scent) do
    alias FunnelWeb.Router.Helpers
    alias FunnelWeb.Endpoint
    case Repo.get_by(GitHub.Repository, git_hub_id: scent.repo_id) do
      nil ->
        Helpers.repositories_url(Endpoint, :index)
      repository ->
        Helpers.repositories_url(Endpoint, :edit, repository.id)
    end
  end

end
