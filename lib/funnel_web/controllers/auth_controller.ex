defmodule FunnelWeb.AuthController do
  use FunnelWeb, :controller
  alias Funnel.GitHubAuth.OAuth

  def login(conn, _params) do
    conn
    |> redirect(external: OAuth.authorize_url!())
  end

  def callback(conn, %{"code" => code}) do
    client = OAuth.get_token!(code: code)

    conn
    |> put_session(:git_hub_access_token, client.token.access_token)
    |> redirect(to: repositories_path(conn, :index))
  end
end
