defmodule TreeChat.Repo do
  use Ecto.Repo,
    otp_app: :tree_chat,
    adapter: Ecto.Adapters.Postgres
end
