defmodule FunnelWeb.PageControllerTest do
  use FunnelWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Funnel"
  end
end
