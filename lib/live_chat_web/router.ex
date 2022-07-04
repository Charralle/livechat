defmodule LiveChatWeb.Router do
  use LiveChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveChatWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # define the new pipeline using auth_plug
  pipeline :authOptional, do: plug(AuthPlugOptional)
  scope "/", LiveChatWeb do
    pipe_through [:browser, :authOptional]

    live "/", MessageLive
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
  end
end
