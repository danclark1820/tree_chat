defmodule TreeChatWeb.MessageController do
  use TreeChatWeb, :controller

  alias TreeChat.Chat

  def index(conn, params) do
    chat = Chat.get_chat(String.to_integer(params["chat_id"]))
    cursor_after = params["cursor_after"]
    cursor_before = params["cursor_before"]

    cond do
      cursor_after ->
        %{entries: messages, metadata: metadata} = Chat.list_messages(chat, after: cursor_after)
        render conn, "index.json", chat: chat, messages: Enum.reverse(messages), replies: Chat.replies_for_messages(messages),  metadata: metadata, reactions: Chat.reactions_for_messages(messages)
      cursor_before ->
        %{entries: messages, metadata: metadata} = Chat.list_messages(chat, before: cursor_before)
        render conn, "index.json", chat: chat, messages: Enum.reverse(messages), replies: Chat.replies_for_messages(messages), metadata: metadata, reactions: Chat.reactions_for_messages(messages)
    end
  end
end
