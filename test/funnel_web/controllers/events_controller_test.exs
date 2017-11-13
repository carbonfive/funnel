defmodule FunnelWeb.EventsControllerTest do
  use FunnelWeb.ConnCase
  import Mock

  test "post /api/events", %{conn: conn} do
    with_mock(Funnel.Investigator, [investigate: fn(_body) -> :noop end]) do
      conn = post conn, "/api/events"
      assert response(conn, 200) =~ "Thanks!"
    end
  end
end
