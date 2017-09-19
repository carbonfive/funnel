defmodule Funnel.Router do
  use Plug.Router
  plug Plug.Parsers, parsers: [:json],
                     pass:  ["*/json"],
                     json_decoder: Poison
  plug :match
  plug :dispatch

  def start_link() do
    {:ok, _} = Plug.Adapters.Cowboy.http Funnel.Router, [], [port: 4000]
  end

  get "/" do
    conn
      |> send_resp(200, "YAY")
      |> halt
  end

  post "/events" do
    IO.puts inspect conn.body_params
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
