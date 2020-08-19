defmodule TreeChatWeb.SearchController do
  use TreeChatWeb, :controller
  alias TreeChat.{Chat, Search, Message, Repo}

  def index(conn, params) do
    message_results = Message |> Search.Messages.run(params["search"]["query"]) |> Repo.all
    chat_results = Chat |> Search.Chats.run(params["search"]["query"]) |> Repo.all
    render conn, "index.html", messages: message_results, chats: chat_results, current_chat: nil
  end
end
