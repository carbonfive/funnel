defmodule FunnelWeb.Router do
  use FunnelWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", FunnelWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/repositories", RepositoriesController, only: [:index, :show, :edit, :update])
  end

  # Other scopes may use custom stacks.
  scope "/api", FunnelWeb do
    pipe_through(:api)

    post("/events", EventsController, :receive)
  end

  scope "/auth", FunnelWeb do
    pipe_through(:browser)

    get("/login", AuthController, :login)

    get("/callback", AuthController, :callback)
  end
end
