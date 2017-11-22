defmodule Funnel.Scent do

  @enforce_keys [
    :owner_login,
    :repo_name,
    :commit_sha,
    :default_branch_name,
    :installation_id,
    :ref,
  ]
  defstruct [
    :owner_login,
    :repo_name,
    :commit_sha,
    :default_branch_name,
    :installation_id,
    :ref,
  ]

  def get_scent(body) do
    %__MODULE__{
      owner_login: body["repository"]["owner"]["login"],
      repo_name: body["repository"]["name"],
      commit_sha: body["head_commit"]["id"],
      default_branch_name: body["repository"]["default_branch"],
      installation_id: body["installation"]["id"],
      ref: body["ref"],
    }
  end

  def is_default_push?(scent) do
    String.ends_with? scent.ref, scent.default_branch_name
  end

end
