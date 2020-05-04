defmodule TreeChat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias TreeChat.Accounts.User

  schema "messages" do
    field :body, :string
    field :name, :string
    belongs_to :user, User
    belongs_to :chat, Chat

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :user_id, :body, :chat_id])
    |> validate_required([:name, :user_id, :body])
    |> assoc_constraint(:user)
    |> assoc_constraint(:chat)
  end
end
