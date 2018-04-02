defmodule FunnelWeb.EventsController do
  use FunnelWeb, :controller
  alias Funnel.Investigator

  def receive(conn, _params) do
    case Funnel.Scent.get_scent(conn.body_params, List.first(get_req_header(conn, "x-github-event"))) do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("Huh?")
        |> halt()
      scent ->
        Investigator.investigate(scent)
        conn
        |> put_status(:ok)
        |> text("Thanks!")
    end

  end

end
