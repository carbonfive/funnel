defmodule FunnelWeb.RepositoriesController do
  use FunnelWeb, :controller
  alias Funnel.Platter
  alias Funnel.GitHub
  alias Funnel.Git
  alias Funnel.Repo

  plug :scrub_params, "repository" when action in [:update]

  def index(conn, _params) do
    alias FunnelWeb.Router.Helpers
    case get_session(conn, :git_hub_access_token) do
      nil ->
        redirect(conn, to: Helpers.auth_path(conn, :login))
      token ->
        repositories = Platter.get_all_user_repositories(token)
        render(conn, "index.html", repositories: repositories)
    end
  end

  def show(conn, %{"id" => id}) do
    repository = Repo.preload(GitHub.get_repository!(id), :strategy)
    render(conn, "show.html", repository: repository)
  end

  def edit(conn, %{"id" => id}) do
    repository = Repo.preload(GitHub.get_repository!(id), :strategy)
    strategies = Git.list_strategies()
    changeset = GitHub.change_repository(repository)
    render(
      conn,
      "edit.html",
      [repository: repository, strategies: strategies, changeset: changeset]
    )
  end

  def update(conn, %{"id" => id, "repository" => repository_params}) do
    repository = Repo.preload(GitHub.get_repository!(id), :strategy)
    strategies = Git.list_strategies()

    case GitHub.update_repository(repository, repository_params) do
      {:ok, repository} ->
        conn
        |> put_flash(:info, "Repository updated successfully.")
        |> redirect(to: repositories_path(conn, :show, repository))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(
        conn,
        "edit.html",
        [repository: repository, strategies: strategies, changeset: changeset]
        )
    end
  end
end
