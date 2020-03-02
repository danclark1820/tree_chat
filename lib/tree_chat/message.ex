defmodule TreeChat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  alias TreeChat.Accounts.User

  schema "messages" do
    field :body, :string
    field :name, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :user_id, :body])
    |> validate_required([:name, :user_id, :body])
    |> assoc_constraint(:user)
  end
end
