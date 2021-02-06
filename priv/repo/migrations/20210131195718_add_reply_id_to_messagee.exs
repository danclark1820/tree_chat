defmodule TreeChat.Repo.Migrations.AddReplyIdToMessagee do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :reply_id, references(:messages)
    end
  end
end
