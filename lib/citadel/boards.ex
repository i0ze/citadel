defmodule Citadel.Boards do
  @moduledoc """
  The Boards context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Citadel.Repo

  alias Citadel.Boards.Board
  alias Citadel.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any board changes.

  The broadcasted messages match the pattern:

    * {:created, %Board{}}
    * {:updated, %Board{}}
    * {:deleted, %Board{}}

  """
  def subscribe_to_board(%Board{} = board) do
    Phoenix.PubSub.subscribe(Citadel.PubSub, "board:#{board.id}")
  end

  defp broadcast_board_update(%Board{} = board, message) do
    Phoenix.PubSub.broadcast(Citadel.PubSub, "board:#{board.id}", message)
  end

  def subscribe_boards(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Citadel.PubSub, "user:#{scope.user.id}:boards")
  end

  defp broadcast_boards(%Scope{} = scope, message) do
    Phoenix.PubSub.broadcast(Citadel.PubSub, "user:#{scope.user.id}:boards", message)
  end

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards(scope)
      [%Board{}, ...]

  """
  def list_boards(%Scope{} = scope) do
    member_board_ids =
      from(m in Citadel.Boards.Membership, where: m.user_id == ^scope.user.id, select: m.board_id)

    query =
      from(b in Board,
        where: b.user_id == ^scope.user.id or b.id in subquery(member_board_ids)
      )

    Repo.all(query) |> Repo.preload([:user, :memberships])
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(scope, 123)
      %Board{}

      iex> get_board!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(%Scope{} = scope, id) do
    Board
    |> Repo.get_by!(id: id, user_id: scope.user.id)
    |> Repo.preload([:memberships, :user])
  end

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(scope, %{field: value})
      {:ok, %Board{}}

      iex> create_board(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(%Scope{} = scope, attrs) do
    with {:ok, board = %Board{}} <-
           %Board{}
           |> Board.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_boards(scope, {:created, board})
      {:ok, board}
    end
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(scope, board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(scope, board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Scope{} = scope, %Board{} = board, attrs) do
    true = board.user_id == scope.user.id

    with {:ok, board = %Board{}} <-
           board
           |> Board.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_boards(scope, {:updated, board})
      {:ok, board}
    end
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(scope, board)
      {:ok, %Board{}}

      iex> delete_board(scope, board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Scope{} = scope, %Board{} = board) do
    true = board.user_id == scope.user.id

    with {:ok, board = %Board{}} <-
           Repo.delete(board) do
      broadcast_boards(scope, {:deleted, board})
      {:ok, board}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(scope, board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Scope{} = scope, %Board{} = board, attrs \\ %{}) do
    true = board.user_id == scope.user.id

    Board.changeset(board, attrs, scope)
  end

  alias Citadel.Boards.Sticker
  alias Citadel.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any sticker changes.

  The broadcasted messages match the pattern:

    * {:created, %Sticker{}}
    * {:updated, %Sticker{}}
    * {:deleted, %Sticker{}}

  """
  def subscribe_stickers(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Citadel.PubSub, "user:#{key}:stickers")
  end

  defp broadcast_sticker(board_id, message) do
    Phoenix.PubSub.broadcast(Citadel.PubSub, "board:#{board_id}", message)
  end

  @doc """
  Creates a sticker.

  ## Examples

      iex> create_sticker(scope, %{field: value})
      {:ok, %Sticker{}}

      iex> create_sticker(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sticker(%Scope{} = scope, %Board{} = board, attrs) do
    is_owner = scope.user.id == board.user_id

    is_editor =
      Enum.any?(board.memberships, &(&1.user_id == scope.user.id and &1.role == "editor"))

    if is_owner or is_editor do
      with {:ok, sticker = %Sticker{}} <-
             board
             |> Ecto.build_assoc(:stickers)
             |> Sticker.changeset(attrs, scope)
             |> Repo.insert() do
        broadcast_sticker(board.id, {:created, sticker})
        {:ok, sticker}
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Updates a sticker.

  ## Examples

      iex> update_sticker(scope, sticker, %{field: new_value})
      {:ok, %Sticker{}}

      iex> update_sticker(scope, sticker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sticker(%Scope{} = scope, %Sticker{} = sticker, attrs) do
    board = Repo.preload(sticker, board: [:memberships]).board

    is_owner = scope.user.id == board.user_id

    is_editor =
      Enum.any?(board.memberships, &(&1.user_id == scope.user.id and &1.role == "editor"))

    if is_owner or is_editor do
      with {:ok, sticker = %Sticker{}} <-
             sticker
             |> Sticker.changeset(attrs, scope)
             |> Repo.update() do
        broadcast_sticker(sticker.board_id, {:updated, sticker})
        {:ok, sticker}
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Deletes a sticker.

  ## Examples

      iex> delete_sticker(scope, sticker)
      {:ok, %Sticker{}}

      iex> delete_sticker(scope, sticker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sticker(%Scope{} = scope, %Sticker{} = sticker) do
    board = Repo.preload(sticker, board: [:memberships]).board

    is_owner = scope.user.id == board.user_id

    is_editor =
      Enum.any?(board.memberships, &(&1.user_id == scope.user.id and &1.role == "editor"))

    if is_owner or is_editor do
      with {:ok, sticker = %Sticker{}} <-
             Repo.delete(sticker) do
        broadcast_sticker(sticker.board_id, {:deleted, sticker})
        {:ok, sticker}
      end
    else
      {:error, :unauthorized}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sticker changes.

  ## Examples

      iex> change_sticker(scope, sticker)
      %Ecto.Changeset{data: %Sticker{}}

  """
  def change_sticker(%Scope{} = scope, %Sticker{} = sticker, attrs \\ %{}) do
    true = sticker.user_id == scope.user.id

    Sticker.changeset(sticker, attrs, scope)
  end

  def get_board(%Scope{} = scope, board_id) do
    board =
      Repo.get_by(Board, id: board_id)
      |> Repo.preload(stickers: from(s in Sticker, select: {s.id, s}))
      |> Repo.preload(:memberships)
      |> Repo.preload(invites: from(i in Citadel.Boards.Invite, select: {i.id, i}))

    board =
      if board == nil do
        false
      else
        %{board | stickers: Map.new(board.stickers), invites: Map.new(board.invites)}
      end

    is_owner = board && board.user_id == scope.user.id
    is_member = board && Enum.any?(board.memberships, &(&1.user_id == scope.user.id))

    if is_owner or is_member do
      {:ok, board}
    else
      {:error, :not_found_or_unauthorized}
    end
  end

  alias Citadel.Boards.Membership
  alias Citadel.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any membership changes.

  The broadcasted messages match the pattern:

    * {:created, %Membership{}}
    * {:updated, %Membership{}}
    * {:deleted, %Membership{}}

  """
  def subscribe_memberships(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Citadel.PubSub, "user:#{key}:memberships")
  end

  defp broadcast_membership(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Citadel.PubSub, "user:#{key}:memberships", message)
  end

  @doc """
  Returns the list of memberships.

  ## Examples

      iex> list_memberships(scope)
      [%Membership{}, ...]

  """
  def list_memberships(%Scope{} = scope) do
    Repo.all_by(Membership, user_id: scope.user.id)
  end

  @doc """
  Gets a single membership.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(scope, 123)
      %Membership{}

      iex> get_membership!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(%Scope{} = scope, id) do
    Repo.get_by!(Membership, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a membership.

  ## Examples

      iex> create_membership(scope, %{field: value})
      {:ok, %Membership{}}

      iex> create_membership(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(%Scope{} = scope, board_id, attrs) do
    # Проверяем, существует ли уже членство для данного пользователя и доски
    existing_membership = Repo.get_by(Membership, user_id: scope.user.id, board_id: board_id)

    if existing_membership do
      {:error, :already_member}
    else
      with {:ok, membership = %Membership{}} <-
             %Membership{}
             |> Membership.changeset(attrs, scope)
             |> Changeset.put_change(:board_id, board_id)
             |> Repo.insert() do
        broadcast_membership(scope, {:created, membership})
        {:ok, membership}
      end
    end
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(scope, membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(scope, membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Scope{} = scope, %Membership{} = membership, attrs) do
    true = membership.user_id == scope.user.id

    with {:ok, membership = %Membership{}} <-
           membership
           |> Membership.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_membership(scope, {:updated, membership})
      {:ok, membership}
    end
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(scope, membership)
      {:ok, %Membership{}}

      iex> delete_membership(scope, membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Scope{} = scope, %Membership{} = membership) do
    true = membership.user_id == scope.user.id

    with {:ok, membership = %Membership{}} <-
           Repo.delete(membership) do
      broadcast_membership(scope, {:deleted, membership})
      {:ok, membership}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(scope, membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Scope{} = scope, %Membership{} = membership, attrs \\ %{}) do
    true = membership.user_id == scope.user.id

    Membership.changeset(membership, attrs, scope)
  end

  alias Citadel.Boards.Invite
  alias Citadel.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any invite changes.

  The broadcasted messages match the pattern:

    * {:created, %Invite{}}
    * {:updated, %Invite{}}
    * {:deleted, %Invite{}}

  """
  def subscribe_invites(id) do
    Phoenix.PubSub.subscribe(Citadel.PubSub, "board:#{id}:invites")
  end

  defp broadcast_invite(id, message) do
    Phoenix.PubSub.broadcast(Citadel.PubSub, "board:#{id}:invites", message)
  end

  @doc """
  Returns the list of invites.

  ## Examples

      iex> list_invites(scope)
      [%Invite{}, ...]

  """
  def list_invites(%Scope{} = scope) do
    Repo.all_by(Invite, user_id: scope.user.id)
  end

  def get_invite_by_hash(hash) do
    Repo.one(from i in Invite, where: i.name == ^hash, select: i)
  end

  @doc """
  Gets a single invite.

  Raises `Ecto.NoResultsError` if the Invite does not exist.

  ## Examples

      iex> get_invite!(scope, 123)
      %Invite{}

      iex> get_invite!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_invite!(%Scope{} = scope, id) do
    Repo.get_by!(Invite, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a invite.

  ## Examples

      iex> create_invite(scope, %{field: value})
      {:ok, %Invite{}}

      iex> create_invite(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite(%Scope{} = scope, %Board{} = board, attrs) do
    with {:ok, invite = %Invite{}} <-
           board
           |> Ecto.build_assoc(:invites)
           |> Invite.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_invite(board.id, {:created, invite})
      {:ok, invite}
    end
  end

  @doc """
  Updates a invite.

  ## Examples

      iex> update_invite(scope, invite, %{field: new_value})
      {:ok, %Invite{}}

      iex> update_invite(scope, invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite(%Scope{} = scope, %Invite{} = invite, attrs) do
    true = invite.user_id == scope.user.id

    with {:ok, invite = %Invite{}} <-
           invite
           |> Invite.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_invite(invite.board_id, {:updated, invite})
      {:ok, invite}
    end
  end

  @doc """
  Deletes a invite.

  ## Examples

      iex> delete_invite(scope, invite)
      {:ok, %Invite{}}

      iex> delete_invite(scope, invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite(%Scope{} = scope, %Invite{} = invite) do
    true = invite.user_id == scope.user.id

    with {:ok, invite = %Invite{}} <-
           Repo.delete(invite) do
      broadcast_invite(invite.board_id, {:deleted, invite})
      {:ok, invite}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invite changes.

  ## Examples

      iex> change_invite(scope, invite)
      %Ecto.Changeset{data: %Invite{}}

  """
  def change_invite(%Scope{} = scope, %Invite{} = invite, attrs \\ %{}) do
    true = invite.user_id == scope.user.id

    Invite.changeset(invite, attrs, scope)
  end
end
