defmodule TreeChatWeb.UserController do
  use TreeChatWeb, :controller

  alias TreeChat.Accounts
  alias TreeChat.Accounts.User
  alias TreeChat.AuthGoogle

  def new(conn, _params) do
    oauth_google_url = AuthGoogle.generate_oauth_url(conn)
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, oauth_google_url: oauth_google_url)
  end

  def create(conn, %{"user" => user_params}) do
    oauth_google_url = AuthGoogle.generate_oauth_url(conn)

    referer = conn.req_headers
    |> List.keyfind("referer", 0)
    |> elem(1)

    parsed_email = Regex.run(~r/([^@]+)/, "#{user_params["email"]}") |> hd()
    generated_user_name = generate_user_name(parsed_email, 0)
    generated_user_params = Map.put(user_params, "username",  generated_user_name)

    case Accounts.create_user(generated_user_params) do
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
        |> render("new.html", changeset: changeset, oauth_google_url: oauth_google_url)
    end
  end

  def edit(_conn, _params) do
  end

  def update(conn, %{"user" => user_params}) do
    oauth_google_url = AuthGoogle.generate_oauth_url(conn)

    user = Accounts.get_user!(conn.assigns[:user_id])

    referer = conn.req_headers
    |> List.keyfind("referer", 0)
    |> elem(1)

    case user_params["current_password"] do
      nil ->
        case Accounts.update_user(user, user_params) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "Account updated successfully.")
            |> redirect(external: referer)
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "There was an error updating your account")
            |> render("edit_account.html", changeset: changeset, oauth_google_url: oauth_google_url)
        end
      current_password ->
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
                |> render("edit_password.html", changeset: changeset, oauth_google_url: oauth_google_url)
            end

          {:error, "invalid password"} ->
            conn
            # Display changeset errors here
            |> put_flash(:error, "There was an error updating your account, password does not match")
            |> render("edit_account.html", %{"user" => user_params}, oauth_google_url: oauth_google_url)
        end
    end
  end

  defp generate_user_name(proposed, acc) do
    case Accounts.get_by_username(proposed) do
      nil ->
        proposed
      %Accounts.User{} ->
        generate_user_name("#{proposed}#{acc + 1}", acc+1)
    end
  end
end
