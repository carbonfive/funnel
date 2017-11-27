defmodule FunnelWeb.RepositoriesControllerTest do
  use FunnelWeb.ConnCase

  describe "index" do
    test "lists all repositories", %{conn: conn} do
      conn = get conn, repositories_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Repositories"
    end
  end
end
