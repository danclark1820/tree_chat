defmodule TreeChatWeb.PasswordController do
  use TreeChatWeb, :controller
  alias TreeChat.Accounts

  def new(_conn, _params) do
  end

  #%{"forgot_password" => %{"email" => email}}
  def create(conn, %{"forgot_password" => %{"email" => email}}) do
    case Accounts.get_by_email(email) do
      user = %Accounts.User{} ->
        conn
        |> put_flash(:info, "A temporary password has been sent to #{email}. Be sure to check your spam folder")
        |> redirect(to: page_path(conn, :index))
      _ ->
        conn
        |> put_flash(:info, "An account was not found for the email provided")
        |> redirect(to: page_path(conn, :index))
    end
  end
end
