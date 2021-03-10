defmodule TreeChat.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TreeChat.Message
  alias Comeonin.Bcrypt

  schema "users" do
    field :encrypted_password, :string
    field :username, :string
    field :full_name, :string
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :email, :string
    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :encrypted_password, :full_name, :first_name, :last_name, :phone_number, :email])
    |> validate_required([:username, :email, :encrypted_password])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> update_change(:encrypted_password, &Bcrypt.hashpwsalt/1)
  end
end
