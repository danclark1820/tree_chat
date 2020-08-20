defmodule TreeChat.Repo.Migrations.AddSearchTsvectorToChats do
  use Ecto.Migration

  def up do
    execute("""
    CREATE INDEX chats_trgm_idx ON chats USING GIN (to_tsvector('english',
      topic || ' ' || description))
    """)
  end

  def down do
    execute("DROP INDEX chats_trgm_idx")
  end
end
