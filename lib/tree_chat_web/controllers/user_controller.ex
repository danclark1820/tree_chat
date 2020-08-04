defmodule TreeChatWeb.UserController do
  use TreeChatWeb, :controller

  alias TreeChat.Accounts
  alias TreeChat.Accounts.User

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do

    referer = conn.req_headers
    |> List.keyfind("referer", 0)
    |> elem(1)

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:current_user_name, user.username)
        |> put_flash(:info, "Account created successfully.")
        |> redirect(external: referer)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        # Display changeset errors here
        |> put_flash(:error, "There was an error creating your account")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(_conn, _params) do
  end

  def update(conn, %{"user" => user_params}) do
    user = Accounts.get_user!(conn.assigns[:user_id])

    referer = conn.req_headers
    |> List.keyfind("referer", 0)
    |> elem(1)

    case Comeonin.Bcrypt.check_pass(user, user_params["current_password"]) do
      {:ok, user} ->
        case  Accounts.update_user(user, Map.delete(user_params, "current_password")) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "Account updated successfully.")
            |> redirect(external: referer)
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "There was an error updating your account")
            |> render("edit_password.html", changeset: changeset)
        end

      {:error, "invalid password"} ->
        conn
        # Display changeset errors here
        |> put_flash(:error, "There was an error updating your account, password does not match")
        |> render("edit_account.html", %{"user" => user_params})
    end
  end
end
