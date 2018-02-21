defmodule Funnel.Investigator.Strategy do
  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Status

  defmodule Sawtooth do
    alias Tentacat.Repositories
    alias Tentacat.Commits

    def investigate_push(scent, tenta_client) do
      # mark as pending
      Helpers.mark_commit_pending(scent, tenta_client)
      # get commit's parent
      commit_parent_sha = Enum.at(Commits.find(scent.commit_sha, scent.owner_login, scent.repo_name, tenta_client)["parents"], 0)["sha"]
      # get base branch head commit
      branch_sha = Helpers.get_base_sha(scent, tenta_client)
      # compare and update status
      chosen_status_body =
        case commit_parent_sha === branch_sha do
          true -> Status.success()
          false -> Status.failure()
        end

      Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, chosen_status_body, tenta_client
    end
  end

  defmodule Squash do
    alias Tentacat.Repositories
    alias Tentacat.Pulls

    def investigate_push(scent, tenta_client) do
      # mark as pending
      Helpers.mark_commit_pending(scent, tenta_client)
      # get open branch commits list
      pr_commits = Pulls.Commits.list scent.owner_login, scent.repo_name, scent.pr_number, tenta_client
      # check length and update status
      chosen_status_body =
        # change me
        case Enum.count(pr_commits) === 1 do
          true -> Status.success()
          false -> Status.failure()
        end

      Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, chosen_status_body, tenta_client
    end
  end

  defmodule Rebase do
    alias Tentacat.Repositories
    alias Tentacat.Pulls

    def investigate_push(scent, tenta_client) do
      # mark as pending
      Helpers.mark_commit_pending(scent, tenta_client)
      # get open pull request's earliest commit
      earliest_pr_commit = Enum.at(Pulls.Commits.list(scent.owner_login, scent.repo_name, scent.pr_number, tenta_client), 0)
      # get that commit's parent
      commit_parent_sha = Enum.at(earliest_pr_commit["parents"], 0)["sha"]
      # get base branch head commit
      branch_sha = Helpers.get_base_sha(scent, tenta_client)
      # compare and update status
      chosen_status_body =
        case commit_parent_sha === branch_sha do
          true -> Status.success()
          false -> Status.failure()
        end

      Repositories.Statuses.create scent.owner_login, scent.repo_name, scent.commit_sha, chosen_status_body, tenta_client
    end
  end
end
