
#This will be a table/repo now...
defmodule TreeChat.Chat do
  @moduledoc """
  The Chats context.
  """
  import Ecto.Query, warn: false
  import Ecto.Changeset

  use Ecto.Schema

  alias TreeChat.{Chat, Message, Accounts.User, Reaction, Repo}



  schema "chats" do
    field :topic, :string
    field :description, :string
    field :created_by, :integer
    belongs_to :user, User, define_field: false
    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:topic, :description, :created_by])
    |> validate_required([:topic, :description, :created_by])
    |> validate_format(:topic, ~r/^[a-zA-Z0-9_]+$/, message: "topic: Formatting error. Only letters, numbers, and underscores are supported, no spaces or special characters.")
    |> unique_constraint(:topic)
    |> assoc_constraint(:user)
  end

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages(nil) do
    Repo.all(from m in Message, where: is_nil(m.chat_id), order_by: m.inserted_at)
  end

  def list_messages(chat = %Chat{}) do
    messages = from m in Message,
                  where: m.chat_id == ^chat.id,
                  order_by: [desc: m.inserted_at, desc: m.id]

    messages
    |> Repo.paginate(cursor_fields: [:inserted_at, :id], sort_direction: :desc, limit: 5)
  end

  def list_messages(chat = %Chat{}, message_id: message_id) do
    messages = from m in Message,
                  where: m.chat_id == ^chat.id,
                  order_by: [desc: m.inserted_at, desc: m.id]

    cursor_for_message = Paginator.cursor_for_record(%Message{id: message_id}, [inserted_at: :desc, id: :desc])

    messages
    |> Repo.paginate(before: cursor_for_message, cursor_fields: [:inserted_at, :id], sort_direction: :desc, limit: 5)
  end

  def list_messages(chat = %Chat{}, after: cursor_after) do
    messages = from m in Message,
                  where: m.chat_id == ^chat.id,
                  order_by: [desc: m.inserted_at, desc: m.id]

    messages
    |> Repo.paginate(after: cursor_after, cursor_fields: [:inserted_at, :id], sort_direction: :desc, limit: 5)
  end

  def list_messages(chat = %Chat{}, before: cursor_before) do
    messages = from m in Message,
                  where: m.chat_id == ^chat.id,
                  order_by: [desc: m.inserted_at, desc: m.id]

    messages
    |> Repo.paginate(before: cursor_before, cursor_fields: [:inserted_at, :id], sort_direction: :desc, limit: 5)
  end

  def reactions_for_messages(messages) do
    message_ids = Enum.map(messages, &(&1.id))
    reactions_for_messages = from m in Message,
                                where: m.id in ^message_ids,
                                preload: :reactions,
                                join: r in Reaction, on: m.id == r.message_id,
                                group_by: [m.id, r.value],
                                select: %{message: m, id: m.id, reaction: r.value, count: count(r.value)}

    reactions_for_messages
    |> Repo.all
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def create_reaction(attrs \\ %{}) do
    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  def delete_reaction(payload) do
    reaction = Repo.get_by(Reaction, %{value: payload["value"], user_id: payload["user_id"], message_id: payload["message_id"]})
    Repo.delete(reaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

  def list_chats do
    Repo.all(Chat)
  end

  def get_chat(nil), do: nil
  def get_chat(id), do: Repo.get(Chat, id)

  def get_chat!(id), do: Repo.get!(Chat, id)

  def get_chat_by_topic(nil), do: nil
  def get_chat_by_topic(topic), do: Repo.get_by(Chat, topic: topic)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = message, attrs) do
    message
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_chat(%Chat{} = chat) do
    Chat.changeset(chat, %{})
  end
end
