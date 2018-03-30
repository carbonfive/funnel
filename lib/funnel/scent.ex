defmodule Funnel.Scent do
  @moduledoc """
  Collection of necessary data (and helpers) from a GitHub pull request (or push) event notification to investigate it
  """

  @enforce_keys [
    :action,
    :owner_login,
    :repo_name,
    :commit_sha,
    :installation_id,
    :branch_name,
    :repo_id
  ]
  defstruct [
    :action,
    :owner_login,
    :repo_name,
    :commit_sha,
    :default_branch_name,
    :installation_id,
    :branch_name,
    :pr_number,
    :repo_id
  ]

  @spec get_scent(%{}, binary) :: %__MODULE__{}
  def get_scent(params, event_type) do
    case event_type do
      "push" -> get_scent_from_push(params)
      "pull_request" -> get_scent_from_pull_request(params)
      _ ->
        require Logger
        Logger.debug("Unkown event type: " <> event_type)
        nil
    end
  end

  @spec is_default_push?(%Funnel.Scent{}) :: boolean
  def is_default_push?(scent) do
    scent.branch_name == scent.default_branch_name
  end

  @spec get_scent_from_pull_request(%{}) :: %__MODULE__{}
  defp get_scent_from_pull_request(params) do
    %__MODULE__{
      action: params["action"],
      owner_login: params["repository"]["owner"]["login"],
      repo_name: params["repository"]["name"],
      commit_sha: params["pull_request"]["head"]["sha"],
      default_branch_name: params["repository"]["default_branch"],
      installation_id: params["installation"]["id"],
      branch_name: params["pull_request"]["head"]["ref"],
      pr_number: params["pull_request"]["number"],
      repo_id: params["repository"]["id"]
    }
  end

  @spec get_scent_from_push(%{}) :: %__MODULE__{}
  defp get_scent_from_push(params) do
    %__MODULE__{
      action: nil,
      owner_login: params["repository"]["owner"]["login"],
      repo_name: params["repository"]["name"],
      commit_sha: params["head_commit"]["id"],
      default_branch_name: params["repository"]["default_branch"],
      installation_id: params["installation"]["id"],
      branch_name: List.last(String.split(params["ref"], "/")),
      repo_id: params["repository"]["id"]
    }
  end

  @spec get_scent_from_pr(map, number) :: %__MODULE__{}
  def get_scent_from_pr(pull_request, installation_id) do
    %__MODULE__{
      action: nil,
      repo_id: pull_request["head"]["repo"]["id"],
      owner_login: pull_request["head"]["repo"]["owner"]["login"],
      repo_name: pull_request["head"]["repo"]["name"],
      commit_sha: pull_request["head"]["sha"],
      installation_id: installation_id,
      branch_name: pull_request["head"]["ref"],
      pr_number: pull_request["number"]
    }
  end

end
