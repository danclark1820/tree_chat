defmodule TreeChatWeb.PageController do
  use TreeChatWeb, :controller
  alias TreeChat.Chats

  def index(conn, _params) do
    messages = Chats.list_messages()
    render conn, "index.html", messages: messages
  end
end
