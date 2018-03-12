defmodule Funnel.Investigator.Strategy do
  @moduledoc """
  A collection of different modules used to _investigate_ (aka audit) a given `scent`.
  """

  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Status

  defmodule Sawtooth do
    @moduledoc """
    The Sawtooth strategy is a combination of squashing *and* rebasing, resulting in a "sawtooth" development branch shape.
    """

    alias Tentacat.Repositories
    alias Tentacat.Commits

    @spec investigate_push(%Funnel.Scent{}, %Tentacat.Client{}) :: any
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
    @moduledoc """
    The Squash strategy ensures there is only one commit in a given pull request.
    """

    alias Tentacat.Repositories
    alias Tentacat.Pulls

    @spec investigate_push(%Funnel.Scent{}, %Tentacat.Client{}) :: any
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
    @moduledoc """
    The Rebase strategy ensures a given pull request is rebased on the base (aka target) branch.
    """
    alias Tentacat.Repositories
    alias Tentacat.Pulls

    @spec investigate_push(%Funnel.Scent{}, %Tentacat.Client{}) :: any
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
