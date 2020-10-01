defmodule TreeChatWeb.RedirectController do
  use TreeChatWeb, :controller
  alias TreeChat.Chat

  def index(conn, _params) do
    redirect(conn, to: "/c/Lobby")
  end
end
