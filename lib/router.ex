defmodule Funnel.Router do
  use Plug.Router
  plug Plug.Parsers, parsers: [:json],
                     pass:  ["*/json"],
                     json_decoder: Poison
  plug :match
  plug :dispatch

  def start_link() do
    {:ok, _} = Plug.Adapters.Cowboy.http Funnel.Router, [], [port: String.to_integer(System.get_env("PORT"))]
  end

  post "/events" do
    spawn fn -> Funnel.Investigator.investigate(conn.body_params) end
    conn
      |> send_resp(200, "YAY")
      |> halt
  end

  match _ do
    conn
      |> send_resp(404, "Not found")
      |> halt
  end
end
