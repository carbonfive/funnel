defmodule Funnel.GitHubAuth.OAuth do
  # copied from https://github.com/scrogson/oauth2
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  # Public API

  def client do
    OAuth2.Client.new(
      strategy: __MODULE__,
      client_id: System.get_env("GITHUB_OAUTH_CLIENT_ID"),
      client_secret: System.get_env("GITHUB_OAUTH_CLIENT_SECRET"),
      redirect_uri: Application.get_env(:funnel, :oauth_redirect_uri),
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    )
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client())
  end

  # you can pass options to the underlying http library via `opts` parameter
  def get_token!(params \\ []) do
    OAuth2.Client.get_token!(
      client(),
      Keyword.merge(params, client_secret: client().client_secret, client_id: client().client_id)
    )
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    client
    |> AuthCode.authorize_url(params)
  end

  def get_token(client, params, headers) do
    client
    |> AuthCode.get_token(params, headers)
  end
end
