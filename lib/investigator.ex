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
    scent = get_scent body
    tenta_client = Tentacat.Client.new(%{access_token: "15f30976459d7dd25b5f1366b3881b2d07b32c53"})

    # mark as pending
    Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], scent["commit_sha"], pending_status_body(), tenta_client

    # get commit branch head
    commit_parent_sha = hd(Tentacat.Commits.find(scent["commit_sha"], scent["owner_login"], scent["repo_name"], tenta_client)["parents"])["sha"]

    # get default branch head
    branch_sha = Tentacat.Repositories.Branches.find(scent["owner_login"], scent["repo_name"], scent["default_branch_name"], tenta_client)["commit"]["sha"]
    
    # compare and update status
    if commit_parent_sha === branch_sha do
      Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], scent["commit_sha"], success_status_body(), tenta_client
    else
      Tentacat.Repositories.Statuses.create scent["owner_login"], scent["repo_name"], scent["commit_sha"], failure_status_body(), tenta_client
    end
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
