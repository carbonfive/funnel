defmodule Funnel.Investigator.Helpers do
  alias Tentacat.Repositories
  alias Funnel.Investigator.Status

  # should fail all branches
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

  def mark_commit_pending(scent, tenta_client) do
    Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, Status.pending(), tenta_client
  end

  def get_base_sha(scent, tenta_client) do
    # see if there's a pull request open for this branch
    List.first(Tentacat.Pulls.filter(scent.owner_login, scent.repo_name, %{state: "open", head: "#{scent.owner_login}:#{scent.branch_name}"}, tenta_client))["base"]["sha"]
  end

  def is_notable_action?(scent) do
    Enum.member?(Application.get_env(:funnel, :notable_actions), scent.action)
  end
end
