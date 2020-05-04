defmodule TreeChatWeb.PageController do
  use TreeChatWeb, :controller
  alias TreeChat.Chat

  def index(conn, _params) do
    messages = Chat.list_messages(conn.params["chat"])
    chats = Chat.list_chats()
    render conn, "index.html", messages: messages, chats: chats
  end
end
