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
    # |> unique_constraint([:value, :user_id, :message_id]) #This also needs a migration
    |> assoc_constraint(:user)
    |> assoc_constraint(:message)
  end
end
