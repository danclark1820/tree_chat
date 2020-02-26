defmodule TreeChat.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TreeChat.Accounts.User
  alias TreeChat.Message
  alias Comeonin.Bcrypt

  schema "users" do
    field :encrypted_password, :string
    field :username, :string
    field :full_name, :string
    field :phone_number, :string
    field :email, :string
    has_many :messages, Message

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :encrypted_password, :full_name, :phone_number, :email])
    |> validate_required([:username, :encrypted_password])
    |> validate_required_inclusion([:email , :phone_number])
    |> unique_constraint(:username)
    |> update_change(:encrypted_password, &Bcrypt.hashpwsalt/1)
  end

  def validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, &present?(changeset, &1)) do
      changeset
    else
      # Add the error to the first field only since Ecto requires a field name for each error.
      add_error(changeset, hd(fields), "One of these fields must be present: #{inspect fields}")
    end
  end

  defp present?(changeset, field) do
    value = get_field(changeset, field)
    value && value != ""
  end
end
