defmodule Funnel.Investigator do

  @doc """
  Handle a given a webhook notification and generate github statuses
  """
  def investigate(body) do
    scent = get_scent(body)
    {:ok, agent_pid} = Agent.start_link(
      fn ->
        Tentacat.Client.new(%{access_token: "token"})
      end
    )
    # check if this is the default branch
    if is_default_push?(body) do
      fail_all_branches(scent, agent_pid)
    else
      investigate_push(scent, agent_pid)
    end
  end

  defp get_scent(body) do
    %{
      "owner_login" => body["repository"]["owner"]["login"],
      "repo_name" => body["repository"]["name"],
      "commit_sha" => body["head_commit"]["id"],
      "default_branch_name" => body["repository"]["default_branch"]
    }
  end

  defp is_default_push?(body) do
    String.ends_with? body["ref"], body["repository"]["default_branch"]
  end

  # should fail all branches
  defp fail_all_branches(scent, agent_pid) do
    tenta_client = Agent.get(agent_pid, fn state -> state end)
    # get all branches in repo
    branches_res = Tentacat.Repositories.Branches.list scent["owner_login"], scent["repo_name"], tenta_client
    Enum.each branches_res, fn(b) ->
      if b["name"] !== scent["default_branch"] do
        spawn fn ->
          Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], b["commit"]["sha"], failure_status_body(), tenta_client
        end
      end
    end
  end

  defp investigate_push(scent, agent_pid) do
    tenta_client = Agent.get(agent_pid, fn state -> state end)
    # mark as pending
    Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], scent["commit_sha"], pending_status_body(), tenta_client

    # get commit branch head
    commit_parent_sha = hd(Tentacat.Commits.find(scent["commit_sha"], scent["owner_login"], scent["repo_name"], tenta_client)["parents"])["sha"]

    # get default branch head
    branch_sha = Tentacat.Repositories.Branches.find(scent["owner_login"], scent["repo_name"], scent["default_branch_name"], tenta_client)["commit"]["sha"]

    # compare and update status
    chosen_status_body =
      case commit_parent_sha === branch_sha do
        true -> success_status_body()
        false -> failure_status_body()
      end

    Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], scent["commit_sha"], chosen_status_body, tenta_client
  end

  defp pending_status_body() do
    %{
       "state": "pending",
       "description": "Investigating your commit",
       "context": "funnel"
     }
  end

  defp success_status_body() do
    %{
       "state": "success",
       "description": "Commit is good to merge",
       "context": "funnel"
     }
  end

  defp failure_status_body() do
    %{
       "state": "failure",
       "description": "Commit must be rebased and squashed",
       "context": "funnel"
     }
  end

end
