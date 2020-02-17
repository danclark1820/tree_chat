defmodule TreeChatWeb.Router do
  use TreeChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_user_token
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TreeChatWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/user", UserController, only: [:create, :new]

    get "/sign-in", SessionController, :new
    post "/sign-in", SessionController, :create
    delete "/sign-out", SessionController, :delete
  end

  defp put_user_token(conn, _) do
    # Is this conn available in the socket, is it the same conn?
    if current_user_id = Plug.Conn.get_session(conn, :current_user_id) do
      token = Phoenix.Token.sign(conn, "user socket", current_user_id)
      # user_name = Plug.Conn.get_session(conn, :user_name)
      assign(conn, :user_token, token)
      # assign(conn, :user_name, user_name)
    else
      conn
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TreeChatWeb do
  #   pipe_through :api
  # end
end
