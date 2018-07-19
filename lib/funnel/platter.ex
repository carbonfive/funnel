defmodule Funnel.Platter do
  alias Funnel.GitHubAuth
  alias Funnel.GitHub
  alias Tentacat.App.Installations
  require Logger

  @spec get_user_installations(binary) :: list
  def get_user_installations(user_access_token) do
    {200, installations, _} =
      Installations.list_for_user(GitHubAuth.get_user_client(user_access_token))

    installations["installations"]
  end

  @spec condense_repository_list(list(map)) :: list(map)
  def condense_repository_list(list), do: condense_repository_list_(list, [])
  defp condense_repository_list_([], acc), do: acc

  defp condense_repository_list_([h | t], acc) do
    repositories = h["repositories"]
    condense_repository_list_(t, repositories ++ acc)
  end

  defp list_repositories(installation_id, user_access_token) do
    {200, repositories, _} =
      Installations.list_repositories_for_user(
        GitHubAuth.get_user_client(user_access_token),
        installation_id
      )

    repositories
  end

  @spec get_user_repositories_for_installation(integer, binary) :: list
  def get_user_repositories_for_installation(installation_id, user_access_token) do
    case list_repositories(installation_id, user_access_token) do
      x when is_map(x) ->
        x["repositories"]

      x when is_list(x) ->
        condense_repository_list(x)

      _ ->
        raise CaseClauseError, message: "Unrecognized repository type"
    end
  end

  @spec get_all_user_repositories(binary) :: list(%GitHub.Repository{})
  def get_all_user_repositories(user_access_token) do
    get_user_installations(user_access_token)
    |> Enum.map(fn installation ->
      get_user_repositories_for_installation(installation["id"], user_access_token)
      |> Enum.map(fn el ->
        el
        |> extract_repository_details_attrs(installation["id"])
        |> pair_repository_details_attrs_with_git_hub_id(el["id"])
      end)
    end)
    |> List.flatten()
    |> Enum.map(fn git_hub_id_and_details ->
      elem(git_hub_id_and_details, 0)
      |> GitHub.get_or_create_repository_with_git_hub_id(elem(git_hub_id_and_details, 1))
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:details, elem(git_hub_id_and_details, 1))
      |> Funnel.Repo.update!()
    end)
  end

  @spec user_has_git_hub_repository_access?(binary, integer) :: boolean
  def user_has_git_hub_repository_access?(user_access_token, git_hub_id) do
    user_access_token
    |> get_user_repository_git_hub_ids()
    |> Enum.member?(git_hub_id)
  end

  @spec get_user_repository_git_hub_ids(binary) :: list(integer)
  defp get_user_repository_git_hub_ids(user_access_token) do
    get_user_installations(user_access_token)
    |> Enum.map(fn installation ->
      get_user_repositories_for_installation(installation["id"], user_access_token)
      |> Enum.map(fn el -> el["id"] end)
    end)
    |> List.flatten()
  end

  @spec extract_repository_details_attrs(map, integer) :: %{
          owner: binary,
          name: binary,
          git_hub_installation_id: integer
        }
  defp extract_repository_details_attrs(response, installation_id) do
    %{
      owner: response["owner"]["login"],
      name: response["name"],
      git_hub_installation_id: installation_id
    }
  end

  @spec pair_repository_details_attrs_with_git_hub_id(
          %{owner: binary, name: binary, git_hub_installation_id: integer},
          integer
        ) :: {integer, %{owner: binary, name: binary, git_hub_installation_id: integer}}
  defp pair_repository_details_attrs_with_git_hub_id(details, git_hub_id) do
    {git_hub_id, details}
  end
end
