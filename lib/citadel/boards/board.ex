defmodule Citadel.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :name, :string

    belongs_to :user, Citadel.Accounts.User
    has_many :stickers, Citadel.Boards.Sticker
    has_many :memberships, Citadel.Boards.Membership
    has_many :invites, Citadel.Boards.Invite

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(board, attrs, user_scope) do
    board
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
  end
end
