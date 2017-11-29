defmodule FunnelWeb.EventsController do
  use FunnelWeb, :controller
  alias Funnel.Investigator

  def receive(conn, _params) do
    Funnel.Scent.get_scent(conn.body_params, List.first(get_req_header(conn, "x-github-event")))
    |> Investigator.investigate()
    text conn, "Thanks!"
  end

end
