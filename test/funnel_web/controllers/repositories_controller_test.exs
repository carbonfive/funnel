defmodule FunnelWeb.RepositoriesControllerTest do
  use ExUnit.Case, async: false
  use FunnelWeb.ConnCase
  import Mock
  alias Funnel.GitHub

  @create_attrs %{git_hub_id: 123456, git_hub_installation_id: 66216, details: %{owner: "ian", name: "cheng"}}
  @update_attrs %{git_hub_id: 654321, details: %{owner: "sara", name: "zac"}}
  @invalid_attrs %{git_hub_id: nil, details: nil}

  def fixture(:repository) do
    {:ok, repository} = GitHub.create_repository(@create_attrs)
    repository
  end

  describe "index" do
    setup [:create_session_conn]

    test "redirects when no github access token", %{conn: conn} do
      with_mocks(platter_mocks(false)) do
        conn = get conn, repositories_path(conn, :index)
        assert html_response(conn, 302)
      end
    end

    test "lists all repositories", %{conn: conn} do
      with_mocks(platter_mocks(true)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> get(repositories_path(conn, :index))
        assert html_response(conn, 200) =~ "Repositories"
      end
    end
  end

  describe "show" do
    setup [:create_session_conn, :create_repository]

    test "404s when user isn't authorized", %{conn: conn, repository: repository} do
      with_mocks(platter_mocks(false)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> get(repositories_path(conn, :show, repository))
        assert html_response(conn, 404)
      end
    end

    test "shows a repository's info", %{conn: conn, repository: repository} do
      with_mocks(platter_mocks(true)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> get(repositories_path(conn, :show, repository))
        assert html_response(conn, 200) =~ @create_attrs.details.owner <> "/" <> @create_attrs.details.name
      end
    end
  end

  describe "edit repository" do
    setup [:create_session_conn, :create_repository]

    test "404s when user isn't authorized", %{conn: conn, repository: repository} do
      with_mocks(platter_mocks(false)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> get(repositories_path(conn, :edit, repository))
        assert html_response(conn, 404)
      end
    end

    test "renders form for editing chosen repository", %{conn: conn, repository: repository} do
      with_mocks(platter_mocks(true)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> get(repositories_path(conn, :edit, repository))
        assert html_response(conn, 200) =~ "Edit Repository"
      end
    end
  end

  describe "update repository" do
    setup [:create_session_conn, :create_repository]

    test "404s when user isn't authorized", %{conn: conn, repository: repository} do
      with_mocks(platter_mocks(false)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> put(repositories_path(conn, :update, repository), repository: @update_attrs)
        assert html_response(conn, 404)
      end
    end

    test "redirects when data is valid", %{conn: conn, repository: repository} do
      with_mocks(platter_mocks(true)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> put(repositories_path(conn, :update, repository), repository: @update_attrs)
        assert redirected_to(conn) == repositories_path(conn, :show, repository)

        conn = get conn, repositories_path(conn, :show, repository)
        assert html_response(conn, 200) =~ @update_attrs.details.owner <> "/" <> @update_attrs.details.name
      end
    end

    test "renders errors when data is invalid", %{conn: conn, repository: repository} do
      with_mocks(platter_mocks(true)) do
        conn =
          conn
          |> fetch_session()
          |> put_session(:git_hub_access_token, "t0kenstr1ng")
          |> put(repositories_path(conn, :update, repository), repository: @invalid_attrs)
        assert html_response(conn, 200) =~ "Edit Repository"
      end
    end
  end

  defp create_repository(_) do
    repository = fixture(:repository)
    {:ok, repository: repository}
  end

  defp create_session_conn(_) do
    conn = session_conn()
    {:ok, conn: conn}
  end

  defp platter_mocks(has_access) do
    [
      {Funnel.Platter, [],
       [
         get_all_user_repositories: fn(_) -> [] end,
         user_has_git_hub_repository_access?: fn(_, _) -> has_access end
       ]},
       {Funnel.Investigator, [],
        [investigate_repository: fn(_) -> :ok end]
      }
    ]
  end
end
