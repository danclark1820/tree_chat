defmodule TreeChatWeb.ChatController do
  use TreeChatWeb, :controller

  alias TreeChat.Chat

  def new(conn, _params) do
    changeset = Chat.change_chat(%Chat{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"chat" => chat_params}) do
    case Chat.create_chat(chat_params) do
      {:ok, chat} ->
        conn
        |> put_flash(:info, "Chat created successfully.")
        |> redirect(to: "/c/#{chat.topic}")

      {:error, %Ecto.Changeset{} = changeset} ->
        errors_map = Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
          Enum.reduce(opts, message, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

        formatted_errors = errors_map
        |> Enum.map(fn {key, errors} ->
          "#{key}: #{Enum.join(errors, ", ")}"
        end)
        |> Enum.join("\n")

        conn
        |> put_flash(:error, formatted_errors)
        |> render("new.html", changeset: changeset)
    end
  end

  def index(conn, params) do
    redirect(conn, to: "/")
  end

  def show(conn, params) do
    case current_chat = Chat.get_chat(params["id"]) do
      %Chat{} ->
        redirect(conn, to: "/c/#{current_chat.topic}?message_id=#{params["message_id"]}")
      nil ->
        redirect(conn, to: "/")
    end
  end
end
