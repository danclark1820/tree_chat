defmodule TreeChatWeb.GoogleAuthController do #This handles app sessions but not channel sessions
  use TreeChatWeb, :controller

  alias TreeChat.Accounts
  alias TreeChat.Accounts.User
  alias TreeChat.AuthGoogle

  def index(conn, %{"code" => code}) do
    {:ok, token} = AuthGoogle.get_token(code, conn)
    {:ok, profile} = AuthGoogle.get_user_profile(token.access_token)
    oauth_google_url = AuthGoogle.generate_oauth_url(conn)

    case Accounts.get_by_email(profile[:email]) do
      user = %Accounts.User{} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:current_user_first, user.first_name)
        |> put_session(:current_user_last, user.last_name)
        |> put_session(:current_user_name, user.username)
        |> put_flash(:info, "Signed in successfully.")
        |> redirect(to: page_path(conn, :index))
      _ ->
        generated_user_name = generate_user_name("#{profile[:given_name]}#{profile[:family_name]}", 0)

        case Accounts.create_user(%{email: profile[:email], username: generated_user_name, first_name: profile[:given_name], last_name: profile[:family_name], full_name: profile[:name], encrypted_password: token[:access_token]}) do
          {:ok, user} ->
            conn
            |> put_session(:current_user_id, user.id)
            |> put_session(:current_user_first, user.first_name)
            |> put_session(:current_user_last, user.last_name)
            |> put_session(:current_user_name, user.username)
            |> put_flash(:info, "Account created successfully.")
            |> redirect(to: page_path(conn, :index))

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "There was an error creating your account")
            |> redirect(to: page_path(conn, :index))
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
