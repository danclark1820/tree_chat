defmodule TreeChatWeb.MessageController do
    use TreeChatWeb, :controller
  
    alias TreeChat.Chat
  
    def show(conn, params) do
      render conn, "show.html", message: Chat.get_message!(params["id"])
    end
end
