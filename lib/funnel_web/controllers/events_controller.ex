defmodule FunnelWeb.EventsController do
  use FunnelWeb, :controller
  alias Funnel.Investigator

  def receive(conn, _params) do
    Investigator.investigate(Funnel.Scent.get_scent(conn.body_params))
    text conn, "Thanks!"
  end

end
