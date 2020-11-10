# Maybe remove the word water from all name spacing?
defmodule TreeChatWeb.WaterCoolerChannel do
  use TreeChatWeb, :channel
  alias TreeChatWeb.PageView
  alias TreeChat.Chat
  alias TreeChat.Repo

  def join("water_cooler:", _payload, socket) do
    {:ok, socket}
  end

  def join("water_cooler:lobby", _payload, socket) do
    {:ok, socket}
  end

  def join("water_cooler:" <> chat_topic, _payload, socket) do
    case Repo.get_by(Chat, topic: chat_topic) do
      nil ->
        {:error, "Chat Topic does not exist"}
      _chat ->
        {:ok, socket}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # payload will include channel id:
  # Eventually we will need per channel authentication
  def handle_in("ping", payload, socket) do
    #Does this go to the whole socket or just the topic?
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (water_cooler:lobby).
  # payload will now include channel id.
  def handle_in("shout", payload, socket = %Phoenix.Socket{topic: "water_cooler:" <> _chat_topic}) do
    # Does this go to the whole socket or just the topic?
    # Currently, if the topic does not exist in the chats table, this will
    # just return nil, which is ok, we will still create messages in the lobby
    # but we can update it so it just not create messages without a channel_id
    # case chat = Repo.get_by(Chat, topic: chat_topic) do
    #   %Chat{} ->
    #     hello_payload = Map.put(payload, "chat_id", chat.id)
    #   nil ->
    #     payload
    # end

    case Chat.create_message(payload) do
      {:ok, message} ->
        new_payload = payload
        |> Map.replace!("body", elem(PageView.decorate_message(payload["body"]), 1))
        |> Map.put("message_id", message.id)

        broadcast socket, "shout", new_payload
        {:noreply, socket}
      {:error, _error} ->
        {:noreply, socket}
    end
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second))
    })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
