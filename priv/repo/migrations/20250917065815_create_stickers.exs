defmodule Citadel.Repo.Migrations.CreateStickers do
  use Ecto.Migration

  def change do
    create table(:stickers) do
      add :text, :string
      add :x, :integer
      add :y, :integer
      add :board_id, references(:boards, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:stickers, [:user_id])
    create index(:stickers, [:board_id])
  end
end
