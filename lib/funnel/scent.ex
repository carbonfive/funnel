defmodule Funnel.Scent do

  @enforce_keys [
    :owner_login,
    :repo_name,
    :commit_sha,
    :default_branch_name,
    :installation_id,
    :branch_name,
  ]
  defstruct [
    :action,
    :owner_login,
    :repo_name,
    :commit_sha,
    :default_branch_name,
    :installation_id,
    :branch_name,
  ]

  def get_scent(params, event_type) do
    case event_type do
      "push" -> get_scent_from_push(params)
      "pull_request" -> get_scent_from_pull_request(params)
    end
  end

  def is_default_push?(scent) do
    scent.branch_name == scent.default_branch_name
  end

  defp get_scent_from_pull_request(params) do
    %__MODULE__{
      action: params["action"],
      owner_login: params["repository"]["owner"]["login"],
      repo_name: params["repository"]["name"],
      commit_sha: params["pull_request"]["head"]["sha"],
      default_branch_name: params["repository"]["default_branch"],
      installation_id: params["installation"]["id"],
      branch_name: params["pull_request"]["head"]["ref"]
    }
  end

  defp get_scent_from_push(params) do
    %__MODULE__{
      owner_login: params["repository"]["owner"]["login"],
      repo_name: params["repository"]["name"],
      commit_sha: params["head_commit"]["id"],
      default_branch_name: params["repository"]["default_branch"],
      installation_id: params["installation"]["id"],
      branch_name: List.last(String.split(params["ref"], "/"))
    }
  end

end
