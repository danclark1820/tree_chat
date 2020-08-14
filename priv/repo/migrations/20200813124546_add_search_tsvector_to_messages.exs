defmodule TreeChat.Repo.Migrations.AddSearchTsvectorToMessages do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION pg_trgm")

    execute("""
    CREATE INDEX messages_trgm_idx ON messages USING GIN (to_tsvector('english',
      body))
    """)
  end

  def down do
    execute("DROP INDEX messages_trgm_idx")
    execute("DROP EXTENSION pg_trgm")
  end
end
