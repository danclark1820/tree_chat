defmodule TreeChat.Presence do
  use Phoenix.Presence,
    otp_app: :tree_chat,
    pubsub_server: TreeChat.PubSub
end
