# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tree_chat,
  ecto_repos: [TreeChat.Repo]

# Configures the endpoint
config :tree_chat, TreeChatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XvECtlvCqf/PRQONdZjBEfMsIwpwQjCgxXxj/DdsUybgAiDYYPSwvRs595LyWJp1",
  render_errors: [view: TreeChatWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: TreeChat.PubSub, adapter: Phoenix.PubSub.PG2]

config :tree_chat, TreeChat.AuthGoogle,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
