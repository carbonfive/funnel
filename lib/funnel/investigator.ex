defmodule Funnel.Investigator do
  alias Funnel.Scent
  alias Tentacat.Repositories
  alias Tentacat.Commits
  alias Funnel.GitHubAuth
  alias Funnel.Investigator.Status

  @doc """
  Handle a given a webhook notification and generate github statuses
  """
  def investigate(scent) do
    {:ok, agent_pid} = Agent.start_link(
      fn ->
        GitHubAuth.get_installation_client(scent.installation_id)
      end
    )
    # check if this is the default branch
    if Scent.is_default_push?(scent) do
      fail_all_branches(scent, agent_pid)
    else
      investigate_push(scent, agent_pid)
    end
  end

  # should fail all branches
  defp fail_all_branches(scent, agent_pid) do
    tenta_client = Agent.get(agent_pid, fn state -> state end)
    # get all branches in repo
    Repositories.Branches.list(scent.owner_login, scent.repo_name, tenta_client)
    # and mark them failed
    |> Enum.filter(fn(b) ->
      b["name"] !== scent.default_branch_name and b["commit"]["sha"] !== scent.commit_sha
      end
    )
    |> Enum.map(fn(b) ->
      Task.async fn ->
        Repositories.Statuses.create scent.owner_login, scent.repo_name, b["commit"]["sha"], Status.failure(), tenta_client
      end
    end)
    |> Task.yield_many(10000)
  end

  defp investigate_push(scent, agent_pid) do
    tenta_client = Agent.get(agent_pid, fn state -> state end)
    # mark as pending
    Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, Status.pending(), tenta_client

    # get commit branch head
    commit_parent_sha = hd(Commits.find(scent.commit_sha, scent.owner_login, scent.repo_name, tenta_client)["parents"])["sha"]

    # get default branch head
    branch_sha = get_base_sha(scent, tenta_client)
    # compare and update status
    chosen_status_body =
      case commit_parent_sha === branch_sha do
        true -> Status.success()
        false -> Status.failure()
      end

    Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, chosen_status_body, tenta_client
  end

  defp get_base_sha(scent, client) do
    # see if there's a pull request open for this branch
    ret = List.first(Tentacat.Pulls.filter(scent.owner_login, scent.repo_name, %{state: "open", head: "#{scent.owner_login}:#{scent.branch_name}"}, client))["head"]["sha"]
    # otherwise, assume the default branch
    if ret == nil do
      ret = Repositories.Branches.find(scent.owner_login, scent.repo_name, scent.default_branch_name, client)["commit"]["sha"]
    end
    ret
  end

end
