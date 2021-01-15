defmodule TreeChatWeb.MessageController do
  use TreeChatWeb, :controller

  alias TreeChat.Chat
  # alias TreeChat.Reaction

  def index(conn, params) do
    chat = Chat.get_chat(String.to_integer(params["chat_id"]))
    cursor_after = params["cursor_after"]
    %{entries: messages, metadata: metadata} = Chat.list_messages(chat, after: cursor_after)
    render conn, "index.json", chat: chat, messages: Enum.reverse(messages), metadata: metadata #, reactions: Chat.reactions_for_messages(messages)#, chats: chats, current_chat: lobby, oauth_google_url: oauth_google_url
  end
end
