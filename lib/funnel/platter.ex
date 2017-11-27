defmodule Funnel.Platter do
  alias Funnel.GitHubAuth
  alias Funnel.GitHub
  alias Tentacat.App.Installations

  @spec get_user_installations(binary) :: list
  def get_user_installations(user_access_token) do
    Installations.list_for_user(GitHubAuth.get_user_client(user_access_token))["installations"]
  end

  @spec get_user_repositories_for_installation(integer, binary) :: list
  def get_user_repositories_for_installation(installation_id, user_access_token) do
    Installations.list_repositories_for_user(installation_id, GitHubAuth.get_user_client(user_access_token))["repositories"]
  end

  # @spec get_all_user_repositories(binary) :: list(Funnel.GitHub.Repository)
  def get_all_user_repositories(user_access_token) do
    get_user_installations(user_access_token)
    |> Enum.map(fn(installation) ->
      get_user_repositories_for_installation(installation["id"], user_access_token)
      |> Enum.map(fn(el) ->
        el["id"]
      end)
    end)
    |> List.flatten
    |> Enum.map(fn(git_hub_id) -> GitHub.get_or_create_repository_with_git_hub_id(git_hub_id) end)
  end

end
