defmodule Citadel.Repo.Migrations.UpdateMemberships do
  use Ecto.Migration

  def change do
    create unique_index(:memberships, [:board_id, :user_id])
  end
end
