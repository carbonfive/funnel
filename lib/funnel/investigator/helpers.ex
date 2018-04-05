defmodule Funnel.Investigator.Helpers do
  @moduledoc """
  A collection of utilities. Mostly wraps Tentacat calls into reasonable actions.
  """

  alias Tentacat.Repositories
  alias Funnel.Investigator.Status
  alias Funnel.GitHubAuth
  alias Funnel.GitHub
  alias Funnel.Repo

  @doc """
  fails the latest commit of every open pull request targeted to this branch
  """
  @spec fail_open_pull_requests(binary, %Funnel.Scent{}, %Tentacat.Client{}) :: atom
  def fail_open_pull_requests(message, scent, tenta_client) do
    # get all prs that are targeted to this branch
    Tentacat.Pulls.filter(scent.owner_login, scent.repo_name, %{state: "open", base: scent.branch_name}, tenta_client)
    # and mark them failed
    |> Enum.map(
      fn(b) ->
        Task.async fn ->
          Repositories.Statuses.create scent.owner_login, scent.repo_name, b["head"]["sha"], Status.failure(message), tenta_client
        end
      end
    )
    |> Task.yield_many(10000)
    :ok
  end

  @doc """
  Sends a pending status for the commit in the `Scent`
  """
  @spec mark_commit_pending(%Funnel.Scent{}, %Tentacat.Client{}) :: any
  def mark_commit_pending(scent, tenta_client) do
    Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, Status.pending(), tenta_client
  end

  @doc """
  Get the latest base branch commit sha for pull requests where this `Scent` is the head branch
  """
  @spec get_base_sha(%Funnel.Scent{}, %Tentacat.Client{}) :: binary
  def get_base_sha(head_scent, tenta_client) do
    # see if there's a pull request open for this branch
    base_branch_name = List.first(Tentacat.Pulls.filter(head_scent.owner_login, head_scent.repo_name, %{state: "open", head: "#{head_scent.owner_login}:#{head_scent.branch_name}"}, tenta_client))["base"]["ref"]
    Tentacat.Repositories.Branches.find(head_scent.owner_login, head_scent.repo_name, base_branch_name, tenta_client)["commit"]["sha"]
  end

  @doc """
  Check if a pull request "action" is in the list of actions we respond to
  """
  @spec is_notable_action?(%Funnel.Scent{}) :: boolean
  def is_notable_action?(scent) do
    Enum.member?(Application.get_env(:funnel, :notable_actions), scent.action)
  end

  @doc """
  Returns the `Scent`'s configured Strategy function.

  This function, when called, will send a status after evaluating the Pull Request.
  """
  @spec strategy_module(%Funnel.Scent{}) :: fun()
  def strategy_module(scent) do
    repository = Repo.get_by!(GitHub.Repository, git_hub_id: scent.repo_id)
    repository = Repo.preload(repository, :strategy)
    atom = String.to_existing_atom("Elixir.Funnel.Investigator.Strategy.#{String.capitalize(repository.strategy.name)}")
    &(atom.investigate_push/2)
  end

  @doc """
  Gets all open pull requests from the GitHub API for the given Repository
  """
  @spec get_open_pull_requests(%Funnel.GitHub.Repository{}) :: list(map)
  def get_open_pull_requests(repository) do
    tenta_client = GitHubAuth.get_installation_client(repository.git_hub_installation_id)
    Tentacat.Pulls.filter(repository.details.owner, repository.details.name, %{state: "open"}, tenta_client)
  end

  @doc """
  Gets all open pull requests' `Scent`s for the given Repository
  """
  @spec get_scents_for_repository(%Funnel.GitHub.Repository{}) :: list(%Funnel.Scent{})
  def get_scents_for_repository(repository) do
    get_open_pull_requests(repository)
    |> Enum.map(fn(el) -> Funnel.Scent.get_scent_from_pr(el, repository.git_hub_installation_id) end)
  end
end
