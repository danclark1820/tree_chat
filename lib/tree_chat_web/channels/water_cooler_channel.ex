# Maybe remove the word water from all name spacing?
defmodule TreeChatWeb.WaterCoolerChannel do
  use TreeChatWeb, :channel
  alias TreeChat.Chat

  # instead of water_cooler:lobby, it will be water_cooler:chat_name,
  # chat name coming from the lobby. The lobby is the home screen and original chat,
  # will be first entry in the in the chats table.
  # We will also want to create routing around chat name.
  def join("water_cooler:lobby", payload, socket) do
    #We allow users to join a channel so they can see the conversation
    #But cannot write in channel until authorized
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # payload will include channel id:
  # Eventually we will need per channel authentication
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (water_cooler:lobby).
  # payload will now include channel id.
  def handle_in("shout", payload, socket) do
    Chat.create_message(payload)
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
end
