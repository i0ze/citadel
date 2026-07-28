defmodule Citadel.Boards.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invites" do
    field :name, :string
    field :expire_at, :utc_datetime

    belongs_to :board, Citadel.Boards.Board
    belongs_to :user, Citadel.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invite, attrs, user_scope) do
    invite
    |> cast(attrs, [:name, :expire_at])
    |> validate_required([:name, :expire_at])
    |> put_change(:user_id, user_scope.user.id)
  end
end
