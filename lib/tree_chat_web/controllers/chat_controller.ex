defmodule TreeChatWeb.ChatController do
  use TreeChatWeb, :controller

  alias TreeChat.Chat

  def new(conn, _params) do
    changeset = Chat.changeset(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chat" => chat_params}) do

    case Chat.create_chat(chat_params) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat created successfully.")
        |> redirect(to: chat_path(conn, chat.id, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        # Display changeset errors here
        |> put_flash(:error, "There was an error creating your chat")
        |> render("new.html", changeset: changeset)
    end
  end
end