defmodule TreeChatWeb.WaterCoolerChannel do
  use TreeChatWeb, :channel
  alias TreeChat.Chats

  def join("water_cooler:lobby", payload, socket) do
    #We allow users to join a channel so they can see the conversation
    #But cannot write in channel until authorized
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (water_cooler:lobby).
  def handle_in("shout", payload, socket) do
    updated_payload = Map.update!(payload, "user_id", &Integer.parse(&1))
    Chats.create_message(updated_payload)
    broadcast socket, "shout", payload
    {:noreply, socket}
  end
end
