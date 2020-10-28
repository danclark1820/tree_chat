defmodule TreeChatWeb.GoogleAuthController do #This handles app sessions but not channel sessions
  use TreeChatWeb, :controller

  alias TreeChat.Accounts
  alias TreeChat.Accounts.User

  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)

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
        parsed_user_name = Regex.replace(~r/@gmail.com/, profile[:email], "") # Don't want to give away users email address
        case Accounts.create_user(%{email: profile[:email], username: parsed_user_name, first_name: profile[:given_name], last_name: profile[:last_name], full_name: profile[:name], encrypted_password: token[:access_token]}) do
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
end
