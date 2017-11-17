defmodule Funnel.Platter do
  alias Funnel.GitHubAuth
  alias Tentacat.App.Installations

  def get_user_installations(user_access_token) do
    Installations.list_for_user(GitHubAuth.get_user_client( user_access_token))
  end

  def get_user_repositories_for_installation(installation_id,   user_access_token) do
    Installations.list_repositories_for_user(installation_id, GitHubAuth.get_user_client(user_access_token))
  end

end
