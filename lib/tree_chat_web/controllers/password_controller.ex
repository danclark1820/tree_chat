defmodule TreeChatWeb.PasswordController do
  use TreeChatWeb, :controller
  alias TreeChat.{Accounts, Email, Mailer}

  def new(_conn, _params) do
  end

  def create(conn, %{"forgot_password" => %{"email" => email}}) do
    case Accounts.get_by_email(email) do
      user = %Accounts.User{} ->
        new_password = random_string(8)
        Accounts.update_user(user, %{encrypted_password: new_password})
        send_password_reset_email(email, new_password)

        conn
        |> put_flash(:info, "A temporary password has been sent to #{email}. Be sure to check your spam folder")
        |> redirect(to: page_path(conn, :index))
      _ ->
        conn
        |> put_flash(:info, "An account was not found for the email provided")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def send_password_reset_email(email, password) do
    Email.password_reset_email(email, password)
    |> Mailer.deliver_now()
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end
end
