defmodule Citadel.Boards.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :role, :string

    belongs_to :user, Citadel.Accounts.User
    belongs_to :board, Citadel.Boards.Board

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs, user_scope) do
    membership
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint([:user_id, :board_id], name: :memberships_board_id_user_id_index)
  end
end
