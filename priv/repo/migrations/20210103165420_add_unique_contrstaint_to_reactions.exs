defmodule TreeChat.Repo.Migrations.AddUniqueContrstaintToReactions do
  use Ecto.Migration

  def change do
    create unique_index(:reactions, [:user_id, :message_id, :value])
  end
end
