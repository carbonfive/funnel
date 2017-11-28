defmodule FunnelWeb.EventsControllerTest do
  use ExUnit.Case, async: false
  use FunnelWeb.ConnCase
  import Funnel.Factory
  import Mock

  test "post /api/events", %{conn: conn} do
    with_mocks([
      {Funnel.Investigator, [], [investigate: fn(_) -> :noop end]},
      {Funnel.Scent, [], [get_scent: fn(_) -> build(:good_push_scent) end]},
    ]) do
      conn = post conn, "/api/events"
      assert response(conn, 200) =~ "Thanks!"
    end
  end
end
