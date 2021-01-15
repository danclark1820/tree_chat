defmodule TreeChatWeb.MessageView do
  use TreeChatWeb, :view

  alias TreeChatWeb.PageView

  def render("index.json", params = %{chat: chat, messages: messages, metadata: metadata}) do
    %{
      chat: chat_json(chat),
      messages: Enum.map(messages, &message_json/1),
      metadata: metadata_json(metadata)
    }
  end

  def chat_json(chat) do
    %{
      id: chat.id
    }
  end


  def message_json(message) do
    %{
      id: message.id,
      name: message.name,
      body: PageView.decorate_message(message.body),
      inserted_at: message.inserted_at
    }
  end

  def metadata_json(metadata) do
    %{
      after: metadata.after
    }
  end

  # def metadata_json(metadata) do
  #   %{
  #     title: todo.title,
  #     description: todo.description,
  #     inserted_at: todo.inserted_at,
  #     updated_at: todo.updated_at
  #   }
  # end
  #
  # def reaction_json(reactions) do
  #   %{
  #     title: todo.title,
  #     description: todo.description,
  #     inserted_at: todo.inserted_at,
  #     updated_at: todo.updated_at
  #   }
  # end
end
