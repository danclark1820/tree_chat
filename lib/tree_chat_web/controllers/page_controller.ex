defmodule TreeChatWeb.PageController do
  use TreeChatWeb, :controller
  alias TreeChat.{Chat, Repo}

  def index(conn, _params) do
    current_chat = Chat.get_chat_by_topic(conn.params["chat"])
    messages = Chat.list_messages(conn.params["chat"])
    chats = Chat.list_chats()
    case messages do
      {:error, _error} ->
        render conn, "index.html", messages: [], chats: chats, current_chat: current_chat
      messages ->
        render conn, "index.html", messages: messages, chats: chats, current_chat: current_chat
    end
  end
end
