defmodule TreeChatWeb.PageController do
  use TreeChatWeb, :controller

  alias TreeChat.Chat
  # alias TreeChat.Reaction

  def index(conn, _params) do
    oauth_google_url = TreeChat.AuthGoogle.generate_oauth_url(conn)
    chats = Chat.list_chats()

    lobby = Chat.get_chat_by_topic("Lobby")
    cond do
      conn.params["chat_topic"] == nil ->
        %{entries: messages, metadata: metadata} = case conn.params["message_id"] do
          nil -> Chat.list_messages(lobby)
          message_id -> Chat.list_messages(lobby, message_id: message_id)
        end
        render conn, "index.html", messages: Enum.reverse(messages), replies: Chat.replies_for_messages(messages), metadata: metadata, reactions: Chat.reactions_for_messages(messages), chats: chats, current_chat: lobby, oauth_google_url: oauth_google_url
      true -> {:ok, "do nothing"}
    end

    case current_chat = Chat.get_chat_by_topic(conn.params["chat_topic"]) do

      %Chat{} ->
        %{entries: messages, metadata: metadata} = case conn.params["message_id"] do
          nil -> Chat.list_messages(current_chat)
          message_id -> Chat.list_messages(current_chat, message_id: message_id)
        end

        conn
        |> put_session(:current_chat_topic, conn.params["chat_topic"])
        |> render "index.html", messages: Enum.reverse(messages), replies: Chat.replies_for_messages(messages), metadata: metadata, reactions: Chat.reactions_for_messages(messages), chats: chats, current_chat: current_chat, oauth_google_url: oauth_google_url
      nil ->
        conn
        |> assign(:oauth_google_url, oauth_google_url)
        |> put_flash(:info, "Chat #{conn.params["chat"]} does not exist, would you like to create it?")
        |> redirect(to: "/c/Lobby")
    end
  end

  def sitemap(conn, __params) do
    chats = Chat.list_chats()

    conn
    |> put_resp_content_type("text/xml")
    |> render("sitemap.xml", chats: chats)
  end
end
