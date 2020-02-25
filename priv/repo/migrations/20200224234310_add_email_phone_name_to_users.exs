defmodule TreeChat.Repo.Migrations.AddEmailPhoneNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :full_name, :text
      add :phone_number, :text
      add :email, :text
    end
  end
end
