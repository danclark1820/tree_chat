defmodule TreeChatWeb.UserController do
  use TreeChatWeb, :controller

  alias TreeChat.Accounts
  alias TreeChat.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "There was an error creating your account")
        |> render("new.html", changeset: changeset)
    end
  end
end
