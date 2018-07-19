defmodule FunnelWeb.EventsController do
  use FunnelWeb, :controller
  alias Funnel.Investigator

  @doc """
  Handle an incoming webhook notification from GitHub
  """
  def receive(conn, _params) do
    case Funnel.Scent.get_scent(
           conn.body_params,
           List.first(get_req_header(conn, "x-github-event"))
         ) do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("Huh?")
        |> halt()

      scent ->
        handle_scent(conn, {scent.type, scent})
    end
  end

  # If it's a pull request notification
  @spec handle_scent(%Plug.Conn{}, tuple) :: %Plug.Conn{}
  defp handle_scent(conn, {:pull_request, scent}) do
    Investigator.investigate(scent)

    conn
    |> put_status(:ok)
    |> text("Thanks!")
  end

  # If it's a push notification
  defp handle_scent(conn, {:push, scent}) do
    Investigator.reevaluate_open_pull_requests(scent)

    conn
    |> put_status(:ok)
    |> text("Thanks!")
  end
end
