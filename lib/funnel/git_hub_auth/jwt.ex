defmodule Funnel.GitHubAuth.Jwt do
  def get_jwt do
    opts = %{
      alg: "RS256",
      key: JsonWebToken.Algorithm.RsaUtil.private_key(System.get_env("GITHUB_PRIVATE_KEY"))
    }
    now = System.os_time(:second)
    payload = %{
      # issued at time
      iat: now,
      # JWT expiration time (10 minute maximum)
      exp: now + (10 * 60),
      # GitHub App's identifier
      iss: Application.get_env(:funnel, :github_app_id)
    }

    JsonWebToken.sign(payload, opts)
  end
end
