defmodule FunnelWeb.EventsControllerTest do
  use ExUnit.Case, async: false
  use FunnelWeb.ConnCase
  import Funnel.Factory
  import Mock

  describe "receive" do
    test "pull request event", %{conn: conn} do
      with_mocks([
        {Funnel.Investigator, [], [investigate: fn _ -> :ok end]},
        {Funnel.Scent, [], [get_scent: fn _, _ -> build(:good_push_scent) end]}
      ]) do
        conn = post(conn, events_path(conn, :receive))
        assert response(conn, 200) =~ "Thanks!"
      end
    end

    test "unkown event", %{conn: conn} do
      with_mocks([
        {Funnel.Investigator, [], [investigate: fn _ -> :ok end]},
        {Funnel.Scent, [], [get_scent: fn _, _ -> nil end]}
      ]) do
        conn = post(conn, events_path(conn, :receive))
        assert response(conn, 404) =~ "Huh?"
      end
    end
  end
end
