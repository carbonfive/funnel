defmodule Funnel.Investigator do
  alias Funnel.Repo
  alias Funnel.GitHubAuth
  alias Funnel.GitHub
  alias Funnel.Scent
  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Status
  alias Tentacat.Repositories

  @doc """
  Call the `Scent`'s configured `Strategy` to publish a Status.
  """
  @spec investigate(%Funnel.Scent{}) :: atom
  def investigate(scent) do
    tenta_client = GitHubAuth.get_installation_client(scent.installation_id)
    cond do
      Helpers.is_notable_action?(scent) and repository_has_strategy?(scent)
        -> apply(Helpers.strategy_module(scent), [scent, tenta_client])
      Helpers.is_notable_action?(scent)
        -> Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, Status.pending_strategy(repository_form_url(scent)), tenta_client
      repository_has_strategy?(scent)
        -> apply(Helpers.strategy_module(scent), [scent, tenta_client])
      true
        -> :noop
    end
  end

  @doc """
  Applies Strategy for each Scent associated with a Repository
  """
  @spec reevaluate_open_pull_requests(%Funnel.Scent{}) :: atom
  def reevaluate_open_pull_requests(scent) do
    tenta_client = GitHubAuth.get_installation_client(scent.installation_id)
    {200, pulls, _} = Tentacat.Pulls.filter(scent.owner_login, scent.repo_name, %{state: "open", base: scent.branch_name}, tenta_client)
    pulls
    |> Enum.map(
      fn(b) ->
        Task.async fn ->
          branch_scent = Scent.get_scent_from_pr(b, scent.installation_id)
          apply(Helpers.strategy_module(branch_scent), [branch_scent, tenta_client])
        end
      end
    )
    |> Task.yield_many(10000)
    :ok
  end

  @doc """
  Reevaluate all open pull requests for a `Repository`
  (Usually called when the `Repository.strategy` has been updated)
  """
  @spec investigate_repository(%Funnel.GitHub.Repository{}) :: atom
  def investigate_repository(repository) do
    Helpers.get_scents_for_repository(repository)
    |> Enum.map(fn(scent) -> investigate(scent) end)
    :ok
  end

  # Check if a `Scent` has a correspending `Repository` record and `Strategy`
  @spec repository_has_strategy?(%Funnel.Scent{}) :: boolean
  defp repository_has_strategy?(scent) do
    try do
      not is_nil(Repo.get_by!(GitHub.Repository, git_hub_id: scent.repo_id).strategy_id)
    rescue
      Ecto.NoResultsError -> false
    end
  end

  # Helper to generate a URL where the user can change the `Repository.strategy`, or redirect them to the Repositories index if there is no record for the Repository
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
