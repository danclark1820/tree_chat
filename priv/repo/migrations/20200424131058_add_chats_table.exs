defmodule TreeChat.Repo.Migrations.AddChatsTable do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :topic, :string
      add :description, :string
      add :created_by, references(:users)

      timestamps()
    end

    alter table(:messages) do
      add :chat_id, references(:chats)
    end

    create unique_index(:chats, [:topic])
  end
end
