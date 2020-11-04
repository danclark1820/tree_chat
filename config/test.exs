use Mix.Config

# Configure your database
config :tree_chat, TreeChat.Repo,
  username: "postgres",
  password: "postgres",
  database: "tree_chat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tree_chat, TreeChatWeb.Endpoint,
  http: [port: 4002],
  server: false

config :tree_chat, TreeChat.AuthGoogle,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Print only warnings and errors during test
config :logger, level: :warn
