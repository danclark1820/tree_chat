defmodule TreeChatWeb.MessageController do
  use TreeChatWeb, :controller

  alias TreeChat.Chat
  # alias TreeChat.Reaction

  def index(conn, params) do
    # require IEx; IEx.pry
    # oauth_google_url = TreeChat.AuthGoogle.generate_oauth_url(conn)
    # chats = Chat.list_chats()
    # redirect to lobby if nothing is passed i
    chat = Chat.get_chat(String.to_integer(params["chat_id"]))
    cursor_after = params["cursor_after"]
    cond do
      conn.params["chat_topic"] == nil ->
        %{entries: messages, metadata: metadata} = Chat.list_messages(chat, after: cursor_after)
        render conn, "index.json", messages: Enum.reverse(messages)#, metadata: metadata, reactions: Chat.reactions_for_messages(messages)#, chats: chats, current_chat: lobby, oauth_google_url: oauth_google_url
      true -> {:ok, "do nothing"}
    end

    # list messages for specifc chat if it exists, redirect to new chats page if it does not
    # case current_chat = Chat.get_chat_by_topic(conn.params["chat_topic"]) do
    #   %Chat{} ->
    #     %{entries: messages, metadata: metadata} = Chat.list_messages(current_chat)
    #     conn
    #     |> put_session(:current_chat_topic, conn.params["chat_topic"])
    #     |> render "index.json", messages: Enum.reverse(messages), metadata: metadata, reactions: Chat.reactions_for_messages(messages), chats: chats, current_chat: current_chat, oauth_google_url: oauth_google_url
    #   nil ->
    #     conn
    #     |> assign(:oauth_google_url, oauth_google_url)
    #     |> put_flash(:info, "Chat #{conn.params["chat"]} does not exist, would you like to create it?")
    #     |> redirect(to: "/c/Lobby")
    # end
  end
end
