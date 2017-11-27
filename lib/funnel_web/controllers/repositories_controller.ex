defmodule FunnelWeb.RepositoriesController do
  use FunnelWeb, :controller
  alias Funnel.Platter
  alias Funnel.GitHub
  alias Funnel.Repo

  def index(conn, _params) do
    repositories = Platter.get_all_user_repositories(get_session(conn, :git_hub_access_token))
    render(conn, "index.html", repositories: repositories)
  end

  def show(conn, %{"id" => id}) do
    repository = Repo.preload GitHub.get_repository!(id), :strategy
    render(conn, "show.html", repository: repository)
  end
end
