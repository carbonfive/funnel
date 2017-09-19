defmodule Funnel.Investigator do

  def get_scent(body) do
    %{
      "owner_login" => body["repository"]["owner"]["login"],
      "repo_name" => body["repository"]["name"],
      "commit_sha" => body["head_commit"]["id"],
      "default_branch_name" => body["repository"]["default_branch"]
    }
  end

  def investigate(body) do
    scent = get_scent(body)
    # check if this is the default branch
    if is_default_push(body) do
      fail_all_branches(scent)
    else
      investigate_push(scent)
    end
  end

  def is_default_push(body) do
    String.ends_with? body["ref"], body["repository"]["default_branch"]
  end

  # should fail all branches?
  def fail_all_branches(scent) do
    # get all branches in repo
    branches_res = Tentacat.Repositories.Branches.list scent["owner_login"], scent["repo_name"], tenta_client()
    Enum.each branches_res, fn(b) ->
      if b["name"] !== scent["default_branch"] do
        spawn fn ->
          Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], b["commit"]["sha"], failure_status_body(), tenta_client()
        end
      end
    end
  end

  def investigate_push(scent) do
    # mark as pending
    Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], scent["commit_sha"], pending_status_body(), tenta_client()

    # get commit branch head
    commit_parent_sha = hd(Tentacat.Commits.find(scent["commit_sha"], scent["owner_login"], scent["repo_name"], tenta_client())["parents"])["sha"]

    # get default branch head
    branch_sha = Tentacat.Repositories.Branches.find(scent["owner_login"], scent["repo_name"], scent["default_branch_name"], tenta_client())["commit"]["sha"]

    # compare and update status
    if commit_parent_sha === branch_sha do
      chosen_status_body = success_status_body()
    else
      chosen_status_body = failure_status_body()
    end

    Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], scent["commit_sha"], chosen_status_body, tenta_client()
  end

  def tenta_client() do
    Tentacat.Client.new(%{access_token: "15f30976459d7dd25b5f1366b3881b2d07b32c53"})
  end

  def pending_status_body() do
    %{
       "state": "pending",
       "description": "Investigating your commit",
       "context": "funnel"
     }
  end

  def success_status_body() do
    %{
       "state": "success",
       "description": "Commit is good to merge",
       "context": "funnel"
     }
  end

  def failure_status_body() do
    %{
       "state": "failure",
       "description": "Commit must be rebased and squashed",
       "context": "funnel"
     }
  end

end
