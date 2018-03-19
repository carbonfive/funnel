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

  @spec get_all_user_repositories(binary) :: list(%GitHub.Repository{})
  def get_all_user_repositories(user_access_token) do
    get_user_installations(user_access_token)
    |> Enum.map(fn(installation) ->
      get_user_repositories_for_installation(installation["id"], user_access_token)
      |> Enum.map(fn(el) ->
        el
        |> extract_repository_details_attrs()
        |> pair_repository_details_attrs_with_git_hub_id(el["id"])
      end)
    end)
    |> List.flatten
    |> Enum.map(fn(git_hub_id_and_details) ->
      GitHub.get_or_create_repository_with_git_hub_id(elem(git_hub_id_and_details, 0))
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:details, elem(git_hub_id_and_details, 1))
      |> Funnel.Repo.update!()
    end)
  end

  @spec extract_repository_details_attrs(map) :: %{owner: binary, name: binary}
  defp extract_repository_details_attrs(response) do
    %{ owner: response["owner"]["login"], name: response["name"] }
  end

  @spec pair_repository_details_attrs_with_git_hub_id( %{owner: binary, name: binary}, integer) :: { integer,  %{owner: binary, name: binary} }
  defp pair_repository_details_attrs_with_git_hub_id(details, git_hub_id) do
    { git_hub_id, details }
  end

end
