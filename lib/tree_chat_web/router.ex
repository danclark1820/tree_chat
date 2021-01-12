defmodule TreeChatWeb.Router do
  use TreeChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_user_token
    plug :put_user_name
    plug :put_user_first
    plug :put_user_last
    plug :put_user_id
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TreeChatWeb do
    pipe_through :browser

    get "/", RedirectController, :index
    get "/c/Lobby", PageController, :index
    get "/c/:chat_topic", PageController, :index
    post "/search", SearchController, :index
    resources "/chat", ChatController, only: [:create, :index, :new, :show]
    resources "/user", UserController, only: [:create, :new, :edit, :update]
    resources "/password", PasswordController, only: [:new, :create]
    get "/privacy-policy", PrivacyPolicyController, :index
    get "/terms-of-service", TermsOfServiceController, :index
    get "/sign-in", SessionController, :new
    post "/sign-in", SessionController, :create
    delete "/sign-out", SessionController, :delete
    get "/auth/google/callback", GoogleAuthController, :index
  end

  scope "/api", TreeChatWeb do
    pipe_through :api

    resources "/messages", MessageController, only: [:index]
  end

  defp put_user_token(conn, _) do
    if current_user_id = Plug.Conn.get_session(conn, :current_user_id) do
      token = Phoenix.Token.sign(conn, "user socket", current_user_id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  defp put_user_name(conn, _) do
    if current_user_name = Plug.Conn.get_session(conn, :current_user_name) do
      assign(conn, :user_name, current_user_name)
    else
      conn
    end
  end

  defp put_user_first(conn, _) do
    if current_user_first = Plug.Conn.get_session(conn, :current_user_first) do
      assign(conn, :user_first, current_user_first)
    else
      conn
    end
  end

  defp put_user_last(conn, _) do
    if current_user_last = Plug.Conn.get_session(conn, :current_user_last) do
      assign(conn, :user_last, current_user_last)
    else
      conn
    end
  end

  defp put_user_id(conn, _) do
    if current_user_id = Plug.Conn.get_session(conn, :current_user_id) do
      assign(conn, :user_id, Integer.to_string(current_user_id))
    else
      conn
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TreeChatWeb do
  #   pipe_through :api
  # end
end
