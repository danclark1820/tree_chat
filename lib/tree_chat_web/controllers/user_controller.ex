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
        |> put_session(:current_user_name, user.username)
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        # Display changeset errors here
        |> put_flash(:error, "There was an error creating your account")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
  end

  def update(conn, %{"user" => user_params}) do
    case Accounts.update_password(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:current_user_name, user.username)
        |> put_flash(:info, "Password updated successfully.")
        |> redirect(to: page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        # Display changeset errors here
        |> put_flash(:error, "Error updating password")
        |> render("edit_password.html", changeset: changeset)
    end
  end

  def forgot_password(conn, %{}) do
  end

  def forgot_username(conn, %{}) do
  end
end
