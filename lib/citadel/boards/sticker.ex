defmodule Citadel.Boards.Sticker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stickers" do
    field :text, :string
    field :x, :integer
    field :y, :integer

    belongs_to :user, Citadel.Accounts.User
    belongs_to :board, Citadel.Boards.Board

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sticker, attrs, user_scope) do
    sticker
    |> cast(attrs, [:text, :x, :y])
    |> validate_required([:text, :x, :y])
    |> put_change(:user_id, user_scope.user.id)
  end
end
