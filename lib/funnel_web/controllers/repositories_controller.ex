defmodule FunnelWeb.RepositoriesController do
  use FunnelWeb, :controller
  alias Funnel.Platter
  alias Funnel.GitHub
  alias Funnel.Git
  alias Funnel.Repo
  alias Funnel.Investigator

  plug :scrub_params, "repository" when action in [:update]
  plug :git_hub_authenticate
  plug :git_hub_authorize_repository when action in [:show, :edit, :update]

  def index(conn, _params) do
    repositories = Platter.get_all_user_repositories(conn.assigns[:git_hub_access_token])
    render(conn, "index.html", repositories: repositories)
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def edit(conn, _params) do
    strategies = Git.list_strategies()
    changeset = GitHub.change_repository(conn.assigns[:repository])
    render(
      conn,
      "edit.html",
      [strategies: strategies, changeset: changeset]
    )
  end

  def update(conn, %{"repository" => repository_params}) do
    case GitHub.update_repository(conn.assigns[:repository], repository_params) do
      {:ok, repository} ->
        Investigator.investigate_repository(repository)
        conn
        |> assign(:repository, repository)
        |> put_flash(:info, "Repository updated successfully.")
        |> redirect(to: repositories_path(conn, :show, repository))
      {:error, %Ecto.Changeset{} = changeset} ->
        strategies = Git.list_strategies()
        repository = conn.assigns[:repository]
        render(
        conn,
        "edit.html",
        [repository: repository, strategies: strategies, changeset: changeset]
        )
    end
  end

  defp git_hub_authenticate(conn, _) do
    alias FunnelWeb.Router.Helpers
    case get_session(conn, :git_hub_access_token) do
      nil ->
        conn
        |> put_flash(:info, "Please authenticate with GitHub")
        |> redirect(to: Helpers.auth_path(conn, :login))
        |> halt()
      token ->
        conn
        |> assign(:git_hub_access_token, token)
    end
  end

  defp git_hub_authorize_repository(conn, _) do
    alias FunnelWeb.ErrorView
    token = conn.assigns[:git_hub_access_token]
    id = conn.params["id"]
    repository = Repo.preload(GitHub.get_repository!(id), :strategy)
    case Platter.user_has_git_hub_repository_access?(token, repository.git_hub_id) do
      true ->
        conn
        |> assign(:repository, repository)
      false ->
        conn
        |> put_status(:not_found)
        |> put_view(ErrorView)
        |> render("404.html")
        |> halt()
    end
  end

end
