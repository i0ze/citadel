defmodule Citadel.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :role, :string
      add :board_id, references(:boards, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:board_id])
  end
end
