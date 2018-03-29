defmodule FunnelWeb.RepositoriesControllerTest do
  use ExUnit.Case, async: false
  use FunnelWeb.ConnCase
  import Mock
  alias Funnel.GitHub

  @create_attrs %{git_hub_id: 123456}
  @update_attrs %{git_hub_id: 654321, details: %{owner: "sara", name: "zac"}}
  @invalid_attrs %{git_hub_id: nil, details: nil}

  def fixture(:repository) do
    {:ok, repository} = GitHub.create_repository(@create_attrs)
    repository
  end

  describe "index" do
    test "lists all repositories", %{conn: conn} do
      with_mocks([
        {Funnel.Platter, [],
         [get_all_user_repositories: fn(_) -> [] end]}
      ]) do
        conn = get conn, repositories_path(conn, :index)
        assert html_response(conn, 302)
      end
    end
  end

  @tag :skip
  describe "show" do
    test "shows a repository's info", %{conn: conn} do
      conn = get conn, repositories_path(conn, :show)
      assert html_response(conn, 200) =~ "Repositories"
    end
  end

  describe "edit repository" do
    setup [:create_repository]

    test "renders form for editing chosen repository", %{conn: conn, repository: repository} do
      conn = get conn, repositories_path(conn, :edit, repository)
      assert html_response(conn, 200) =~ "Edit Repository"
    end
  end

  describe "update repository" do
    setup [:create_repository]

    test "redirects when data is valid", %{conn: conn, repository: repository} do
      conn = put conn, repositories_path(conn, :update, repository), repository: @update_attrs
      assert redirected_to(conn) == repositories_path(conn, :show, repository)

      conn = get conn, repositories_path(conn, :show, repository)
      assert html_response(conn, 200) =~ @update_attrs.details.owner <> "/" <> @update_attrs.details.name
    end

    test "renders errors when data is invalid", %{conn: conn, repository: repository} do
      conn = put conn, repositories_path(conn, :update, repository), repository: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Repository"
    end
  end

  defp create_repository(_) do
    repository = fixture(:repository)
    {:ok, repository: repository}
  end
end
