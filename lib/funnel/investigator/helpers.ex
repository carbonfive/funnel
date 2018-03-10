defmodule Funnel.Investigator.Helpers do
  @moduledoc """
  A collection of utilities for the different `Funnel.Investigator` strategies.

  Mostly wraps Tentacat calls into reasonable actions.
  """

  alias Tentacat.Repositories
  alias Funnel.Investigator.Status

  @doc """
  fails the latest commit of every open pull request targeted to this branch
  """
  @spec fail_open_pull_requests(%Funnel.Scent{}, %Tentacat.Client{}) :: any
  def fail_open_pull_requests(scent, tenta_client) do
    # get all prs that are targeted to this branch
    Tentacat.Pulls.filter(scent.owner_login, scent.repo_name, %{state: "open", base: scent.branch_name}, tenta_client)
    # and mark them failed
    |> Enum.map(
      fn(b) ->
        Task.async fn ->
          Repositories.Statuses.create scent.owner_login, scent.repo_name, b["head"]["sha"], Status.failure(), tenta_client
        end
      end
    )
    |> Task.yield_many(10000)
  end

  @spec mark_commit_pending(%Funnel.Scent{}, %Tentacat.Client{}) :: any
  def mark_commit_pending(scent, tenta_client) do
    Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, Status.pending(), tenta_client
  end

  @spec get_base_sha(%Funnel.Scent{}, %Tentacat.Client{}) :: charlist
  def get_base_sha(scent, tenta_client) do
    # see if there's a pull request open for this branch
    List.first(Tentacat.Pulls.filter(scent.owner_login, scent.repo_name, %{state: "open", head: "#{scent.owner_login}:#{scent.branch_name}"}, tenta_client))["base"]["sha"]
  end

  @spec is_notable_action?(%Funnel.Scent{}) :: boolean
  def is_notable_action?(scent) do
    Enum.member?(Application.get_env(:funnel, :notable_actions), scent.action)
  end
end
