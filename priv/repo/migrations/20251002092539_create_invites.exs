defmodule Citadel.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :name, :string
      add :expire_at, :utc_datetime
      add :board_id, references(:boards, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:invites, [:user_id])

    create index(:invites, [:board_id])
  end
end
