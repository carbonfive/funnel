defmodule Funnel.GitHubAuth do
  @moduledoc """
  Helper functions for getting authorized Tentacat clients
  """
  
  alias Funnel.GitHubAuth.Jwt
  alias Tentacat.App
  alias Tentacat.Client

  @spec get_installation_client(integer) :: %Tentacat.Client{}
  def get_installation_client(installation_id) do
    Client.new(%{access_token: get_installation_access_token(installation_id)})
  end

  @spec get_app_client() :: %Tentacat.Client{}
  def get_app_client do
    Client.new(%{jwt: Jwt.get_jwt()})
  end

  @spec get_user_client(charlist) :: %Tentacat.Client{}
  def get_user_client(access_token) do
    Client.new(%{access_token: access_token})
  end

  @spec get_installation_access_token(integer) :: charlist
  defp get_installation_access_token(id) do
    elem(App.Installations.token(id, get_app_client()), 1)["token"]
  end

end
