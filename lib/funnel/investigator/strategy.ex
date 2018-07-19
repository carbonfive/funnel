defmodule Funnel.Investigator.Strategy do
  @moduledoc """
  A collection of different modules used to _investigate_ (aka audit) a given `Scent`.
  """

  alias Funnel.Investigator.Helpers
  alias Funnel.Investigator.Status

  defmodule Sawtooth do
    @moduledoc """
    The Sawtooth strategy is a combination of squashing *and* rebasing, resulting in a "sawtooth" development branch shape.
    """

    alias Tentacat.Repositories
    alias Tentacat.Commits

    @spec investigate_push(%Funnel.Scent{}, %Tentacat.Client{}) :: atom
    def investigate_push(scent, tenta_client) do
      # mark as pending
      Helpers.mark_commit_pending(scent, tenta_client)
      # get commit's parent
      {200, commit, _} =
        Commits.find(tenta_client, scent.commit_sha, scent.owner_login, scent.repo_name)

      commit_parent_sha = Enum.at(commit["parents"], 0)["sha"]
      # get base branch head commit
      branch_sha = Helpers.get_base_sha(scent, tenta_client)
      # compare and update status
      chosen_status_body = get_status(commit_parent_sha === branch_sha)

      Repositories.Statuses.create(
        tenta_client,
        scent.owner_login,
        scent.repo_name,
        scent.commit_sha,
        chosen_status_body
      )

      :ok
    end

    @spec get_status(boolean) :: map
    defp get_status(comparison) do
      if comparison,
        do: Status.success(),
        else: Status.failure("Branch must be rebased and squashed")
    end
  end

  defmodule Squash do
    @moduledoc """
    The Squash strategy ensures there is only one commit in a given pull request.
    """

    alias Tentacat.Repositories
    alias Tentacat.Pulls

    @spec investigate_push(%Funnel.Scent{}, %Tentacat.Client{}) :: atom
    def investigate_push(scent, tenta_client) do
      # mark as pending
      Helpers.mark_commit_pending(scent, tenta_client)
      # get open branch commits list
      {200, pr_commits, _} =
        Pulls.Commits.list(tenta_client, scent.owner_login, scent.repo_name, scent.pr_number)

      # check length and update status
      chosen_status_body = get_status(Enum.count(pr_commits) === 1)

      Repositories.Statuses.create(
        tenta_client,
        scent.owner_login,
        scent.repo_name,
        scent.commit_sha,
        chosen_status_body
      )

      :ok
    end

    @spec get_status(boolean) :: map
    defp get_status(comparison) do
      if comparison,
        do: Status.success(),
        else: Status.failure("Branch must be squashed")
    end
  end

  defmodule Rebase do
    @moduledoc """
    The Rebase strategy ensures a given pull request is rebased on the base (aka target) branch.
    """
    alias Tentacat.Repositories
    alias Tentacat.Pulls

    @spec investigate_push(%Funnel.Scent{}, %Tentacat.Client{}) :: atom
    def investigate_push(scent, tenta_client) do
      # mark as pending
      Helpers.mark_commit_pending(scent, tenta_client)
      # get open pull request's earliest commit
      {_, commits, _} =
        Pulls.Commits.list(tenta_client, scent.owner_login, scent.repo_name, scent.pr_number)

      earliest_pr_commit = Enum.at(commits, 0)
      # get that commit's parent
      commit_parent_sha = Enum.at(earliest_pr_commit["parents"], 0)["sha"]
      # get base branch head commit
      branch_sha = Helpers.get_base_sha(scent, tenta_client)
      # compare and update status
      chosen_status_body = get_status(commit_parent_sha === branch_sha)

      Repositories.Statuses.create(
        tenta_client,
        scent.owner_login,
        scent.repo_name,
        scent.commit_sha,
        chosen_status_body
      )

      :ok
    end

    @spec get_status(boolean) :: map
    defp get_status(comparison) do
      if comparison,
        do: Status.success(),
        else: Status.failure("Branch must be rebased")
    end
  end
end
