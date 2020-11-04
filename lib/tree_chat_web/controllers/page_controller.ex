defmodule TreeChatWeb.PageController do
  use TreeChatWeb, :controller

  alias TreeChat.Chat

  def index(conn, _params) do
    oauth_google_url = TreeChat.AuthGoogle.generate_oauth_url(conn)
    chats = Chat.list_chats()

    # redirect to lobby if nothing is passed i
    lobby = Chat.get_chat_by_topic("Lobby")
    cond do
      conn.params["chat_topic"] == nil ->
        render conn, "index.html", messages: Chat.list_messages(lobby), chats: chats, current_chat: lobby, oauth_google_url: oauth_google_url
      true -> {:ok, "do nothing"}
    end

    # list messages for specifc chat if it exists, redirect to new chats page if it does not
    case current_chat = Chat.get_chat_by_topic(conn.params["chat_topic"]) do
      %Chat{} ->
        render conn, "index.html", messages: Chat.list_messages(current_chat), chats: chats, current_chat: current_chat, oauth_google_url: oauth_google_url
      nil ->
        conn
        |> assign(:oauth_google_url, oauth_google_url)
        |> put_flash(:info, "Chat #{conn.params["chat"]} does not exist, would you like to create it?")
        |> redirect(to: "/c/Lobby")
    end
  end
end
