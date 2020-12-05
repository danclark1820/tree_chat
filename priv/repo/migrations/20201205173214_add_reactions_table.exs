defmodule TreeChat.Repo.Migrations.AddReactionsTable do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :value, :string
      add :user_id, references(:users)
      add :message_id, references(:messages)

      timestamps
    end
  end
end
