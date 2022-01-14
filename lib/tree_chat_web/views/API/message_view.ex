defmodule TreeChatWeb.API.MessageView do
  #Need to make sure you don't break pagination json rendering of messages
  use TreeChatWeb, :view

  alias TreeChatWeb.PageView

  def render("index.json", params = %{chat: chat, messages: messages, replies: replies, reactions: reactions, metadata: metadata}) do
    %{
      chat: chat_json(chat),
      messages: Enum.map(messages, &message_json/1),
      replies: Enum.map(replies, &message_json/1),
      reactions: Enum.map(reactions, &reaction_json/1),
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
      chat_id: message.chat_id,
      name: message.name,
      body: PageView.decorate_message(message.body),
      undecorated_body: message.body,
      reply_id: message.reply_id,
      inserted_at: message.inserted_at
    }
  end

  def reaction_json(reaction) do
    %{
      value: reaction.reaction,
      count: reaction.count,
      message_id: reaction.message.id,
      user_ids: Enum.filter(reaction.message.reactions, & &1.value == reaction.reaction) |> Enum.map(& (Integer.to_string(&1.user_id)))
    }
  end

  def metadata_json(metadata) do
    %{
      after: metadata.after,
      before: metadata.before
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
