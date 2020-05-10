defmodule TreeChatWeb.PageController do
  use TreeChatWeb, :controller
  alias TreeChat.{Chat, Repo}

  def index(conn, _params) do
    chats = Chat.list_chats()

    # redirect to lobby if nothing is passed in
    cond do
      conn.params["chat"] == nil ->
        # redirect(conn, to: page_path(conn, :index))
        render conn, "index.html", messages: Chat.list_messages("lobby"), chats: chats, current_chat: nil
      # String.downcase(conn.params["chat"]) == "lobby" ->
      #   render conn, "index.html", messages: Chat.list_messages("lobby"), chats: chats, current_chat: nil
      true -> {:ok, "do nothing"}
    end

    # list messages for specifc chat if it exists, redirect to new chats page if it does not
    case current_chat = Chat.get_chat_by_topic(conn.params["chat"]) do
      %Chat{} ->
        render conn, "index.html", messages: Chat.list_messages(conn.params["chat"]), chats: chats, current_chat: current_chat
      nil ->
        conn
        |> put_flash(:info, "Chat #{conn.params["chat"]} does not exist, would you like to create it?")
        |> redirect(to: chat_path(conn, :new))
    end
  end
end
