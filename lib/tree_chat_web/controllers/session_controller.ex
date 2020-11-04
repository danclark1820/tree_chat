defmodule TreeChatWeb.SessionController do #This handles app sessions but not channel sessions
  use TreeChatWeb, :controller

  alias TreeChat.Accounts
  alias TreeChat.AuthGoogle

  def new(conn, _params) do
    oauth_google_url = AuthGoogle.generate_oauth_url(conn)
    render(conn, "new.html", [oauth_google_url: oauth_google_url])
  end

  def create(conn, %{"session" => auth_params}) do
    oauth_google_url = AuthGoogle.generate_oauth_url(conn)
    user = Accounts.get_by_email(auth_params["email"])

    refferer = conn.req_headers
    |> List.keyfind("referer", 0)
    |> elem(1)

    case Comeonin.Bcrypt.check_pass(user, auth_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_session(:current_user_first, user.first_name)
        |> put_session(:current_user_last, user.last_name)
        |> put_session(:current_user_name, user.username)
        |> put_flash(:info, "Signed in successfully.")
        |> assign(:oauth_google_url, oauth_google_url)
        |> smart_redirect(refferer) #conn[:req_headers][req_refferer]
      {:error, _} ->
        conn
        |> assign(:oauth_google_url, oauth_google_url)
        |> put_flash(:error, "There was a problem with your email/password")
        |> render("new.html", [oauth_google_url: oauth_google_url])
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user_id)
    |> put_flash(:info, "Signed out successfully.")
    |> redirect(to: page_path(conn, :index))
  end

  defp smart_redirect(conn, refferer) do
    parsed_refferer = String.split(refferer, "/")

    if Enum.any?(parsed_refferer, fn x -> x == "sign-in" end) || !Enum.any?(parsed_refferer, fn x -> x == "cooler.chat" || x == "localhost:4000" end) do
      redirect(conn, to: page_path(conn, :index))
    else
      redirect(conn, external: refferer)
    end
  end
end
