defmodule TreeChatWeb.PasswordController do
  use TreeChatWeb, :controller
  alias TreeChat.Accounts

  def new(_conn, _params) do
  end

  #%{"forgot_password" => %{"email" => email}}
  def create(_conn, %{"forgot_password" => %{"email" => email}}) do
    case Accounts.get_by_email(email) do
      {:ok, user} ->
        IO.puts("PIZZA")
      {:error, error} ->
        IO.puts("Error")
    end
  end
end
