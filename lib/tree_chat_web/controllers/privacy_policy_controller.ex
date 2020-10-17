defmodule TreeChatWeb.PrivacyPolicyController do
  use TreeChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
