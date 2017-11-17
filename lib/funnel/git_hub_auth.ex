defmodule Funnel.GitHubAuth do
  alias Funnel.GitHubAuth.Jwt
  alias Tentacat.App
  alias Tentacat.Client

  def get_installation_client(installation_id) do
    Client.new(%{access_token: get_installation_access_token(installation_id)})
  end

  def get_app_client do
    Client.new(%{jwt: Jwt.get_jwt()})
  end

  def get_user_client(access_token) do
    Client.new(%{access_token: access_token})
  end

  defp get_installation_access_token(id) do
    elem(App.Installations.token(id, get_app_client()), 1)["token"]
  end

end
