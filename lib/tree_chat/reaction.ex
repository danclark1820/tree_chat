defmodule TreeChat.Reaction do
  use Ecto.Schema

  import Ecto.Changeset
  alias TreeChat.Accounts.User
  alias TreeChat.Message

  schema "reactions" do
    field :value, :string
    belongs_to :user, User
    belongs_to :message, Message

    timestamps()
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:value, :user_id, :message_id])
    |> validate_required([:value, :user_id, :message_id])
    |> unique_constraint(:unique_user_message_value, name: :reactions_user_id_message_id_value_index)
    |> assoc_constraint(:user)
    |> assoc_constraint(:message)
  end
end
