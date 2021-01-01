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

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("shout", payload, socket = %Phoenix.Socket{topic: "water_cooler:" <> _chat_topic}) do
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

  def handle_in("reaction", payload, socket = %Phoenix.Socket{topic: "water_cooler:" <> _chat_topic}) do
    case Chat.create_reaction(payload) do
      {:ok, reaction} ->
        broadcast socket, "increment_reaction", payload
        {:noreply, socket}
      {:error, _error} ->
        {:noreply, socket}
    end
  end
end
