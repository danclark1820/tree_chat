defmodule TeacherWeb.Helpers.Auth do
  def signed_into_app?(conn) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    if user_id, do: !!TreeChat.Repo.get(TreeChat.Accounts.User, user_id)
  end
end
