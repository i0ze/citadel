defmodule Citadel.BoardsTest do
  use Citadel.DataCase

  alias Citadel.Boards

  describe "boards" do
    alias Citadel.Boards.Board

    import Citadel.AccountsFixtures, only: [user_scope_fixture: 0]
    import Citadel.BoardsFixtures

    @invalid_attrs %{name: nil}

    test "list_boards/1 returns all scoped boards" do
      owner_scope = user_scope_fixture()
      member_scope = user_scope_fixture()
      
      board = board_fixture(owner_scope)
      membership_fixture(member_scope, %{board_id: board.id, role: "viewer"})
      
      other_board = board_fixture(user_scope_fixture())
      
      assert [board | _] = Boards.list_boards(owner_scope)
      assert [board | _] = Boards.list_boards(member_scope)
      refute other_board in Boards.list_boards(owner_scope)
      refute other_board in Boards.list_boards(member_scope)
    end

    test "get_board!/2 returns the board with given id" do
      scope = user_scope_fixture()
      board = board_fixture(scope)
      other_scope = user_scope_fixture()
      assert Boards.get_board!(scope, board.id) == board
      assert_raise Ecto.NoResultsError, fn -> Boards.get_board!(other_scope, board.id) end
    end

    test "create_board/2 with valid data creates a board" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Board{} = board} = Boards.create_board(scope, valid_attrs)
      assert board.name == "some name"
      assert board.user_id == scope.user.id
    end

    test "create_board/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Boards.create_board(scope, @invalid_attrs)
    end

    test "update_board/3 with valid data updates the board" do
      scope = user_scope_fixture()
      board = board_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Board{} = board} = Boards.update_board(scope, board, update_attrs)
      assert board.name == "some updated name"
    end

    test "update_board/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      board = board_fixture(scope)

      assert_raise MatchError, fn ->
        Boards.update_board(other_scope, board, %{})
      end
    end

    test "update_board/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      board = board_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Boards.update_board(scope, board, @invalid_attrs)
      assert board == Boards.get_board!(scope, board.id)
    end

    test "delete_board/2 deletes the board" do
      scope = user_scope_fixture()
      board = board_fixture(scope)
      assert {:ok, %Board{}} = Boards.delete_board(scope, board)
      assert_raise Ecto.NoResultsError, fn -> Boards.get_board!(scope, board.id) end
    end

    test "delete_board/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      board = board_fixture(scope)
      assert_raise MatchError, fn -> Boards.delete_board(other_scope, board) end
    end

    test "change_board/2 returns a board changeset" do
      scope = user_scope_fixture()
      board = board_fixture(scope)
      assert %Ecto.Changeset{} = Boards.change_board(scope, board)
    end
  end

  describe "stickers" do
    alias Citadel.Boards.Sticker

    import Citadel.AccountsFixtures, only: [user_scope_fixture: 0]
    import Citadel.BoardsFixtures

    @invalid_attrs %{x: nil, y: nil, text: nil}

    test "create_sticker/3 with valid data creates a sticker" do
      valid_attrs = %{x: 42, y: 42, text: "some text"}
      scope = user_scope_fixture()
      board = board_fixture(scope)

      assert {:ok, %Sticker{} = sticker} = Boards.create_sticker(scope, board, valid_attrs)
      assert sticker.x == 42
      assert sticker.y == 42
      assert sticker.text == "some text"
      assert sticker.user_id == scope.user.id
    end

    test "create_sticker/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      board = board_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Boards.create_sticker(scope, board, @invalid_attrs)
    end

    test "update_sticker/3 with valid data updates the sticker" do
      scope = user_scope_fixture()
      sticker = sticker_fixture(scope)
      update_attrs = %{x: 43, y: 43, text: "some updated text"}

      assert {:ok, %Sticker{} = sticker} = Boards.update_sticker(scope, sticker, update_attrs)
      assert sticker.x == 43
      assert sticker.y == 43
      assert sticker.text == "some updated text"
    end

    test "update_sticker/3 with invalid scope returns error" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      sticker = sticker_fixture(scope)

      assert {:error, :unauthorized} = Boards.update_sticker(other_scope, sticker, %{})
    end

    test "update_sticker/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      sticker = sticker_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Boards.update_sticker(scope, sticker, @invalid_attrs)
    end

    test "delete_sticker/2 deletes the sticker" do
      scope = user_scope_fixture()
      sticker = sticker_fixture(scope)
      assert {:ok, %Sticker{}} = Boards.delete_sticker(scope, sticker)
    end

    test "delete_sticker/2 with invalid scope returns error" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      sticker = sticker_fixture(scope)
      assert {:error, :unauthorized} = Boards.delete_sticker(other_scope, sticker)
    end

    test "change_sticker/2 returns a sticker changeset" do
      scope = user_scope_fixture()
      sticker = sticker_fixture(scope)
      assert %Ecto.Changeset{} = Boards.change_sticker(scope, sticker)
    end
  end

  describe "memberships" do
    alias Citadel.Boards.Membership

    import Citadel.AccountsFixtures, only: [user_scope_fixture: 0]
    import Citadel.BoardsFixtures

    @invalid_attrs %{role: nil}

    test "list_memberships/1 returns all scoped memberships" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership = membership_fixture(scope)
      other_membership = membership_fixture(other_scope)
      assert Boards.list_memberships(scope) == [membership]
      assert Boards.list_memberships(other_scope) == [other_membership]
    end

    test "get_membership!/2 returns the membership with given id" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      other_scope = user_scope_fixture()
      assert Boards.get_membership!(scope, membership.id) == membership

      assert_raise Ecto.NoResultsError, fn ->
        Boards.get_membership!(other_scope, membership.id)
      end
    end

    test "create_membership/3 with valid data creates a membership" do
      valid_attrs = %{role: "some role"}
      scope = user_scope_fixture()
      board = board_fixture(scope)

      assert {:ok, %Membership{} = membership} =
               Boards.create_membership(scope, board.id, valid_attrs)

      assert membership.role == "some role"
      assert membership.user_id == scope.user.id
    end

    test "create_membership/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      board = board_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Boards.create_membership(scope, board.id, @invalid_attrs)
    end

    test "update_membership/3 with valid data updates the membership" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      update_attrs = %{role: "some updated role"}

      assert {:ok, %Membership{} = membership} =
               Boards.update_membership(scope, membership, update_attrs)

      assert membership.role == "some updated role"
    end

    test "update_membership/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership = membership_fixture(scope)

      assert_raise MatchError, fn ->
        Boards.update_membership(other_scope, membership, %{})
      end
    end

    test "update_membership/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Boards.update_membership(scope, membership, @invalid_attrs)

      assert membership == Boards.get_membership!(scope, membership.id)
    end

    test "delete_membership/2 deletes the membership" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert {:ok, %Membership{}} = Boards.delete_membership(scope, membership)
      assert_raise Ecto.NoResultsError, fn -> Boards.get_membership!(scope, membership.id) end
    end

    test "delete_membership/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert_raise MatchError, fn -> Boards.delete_membership(other_scope, membership) end
    end

    test "change_membership/2 returns a membership changeset" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert %Ecto.Changeset{} = Boards.change_membership(scope, membership)
    end
  end

  describe "invites" do
    alias Citadel.Boards.Invite

    import Citadel.AccountsFixtures, only: [user_scope_fixture: 0]
    import Citadel.BoardsFixtures

    @invalid_attrs %{name: nil, expire_at: nil}

    test "list_invites/1 returns all scoped invites" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      invite = invite_fixture(scope)
      other_invite = invite_fixture(other_scope)
      assert Boards.list_invites(scope) == [invite]
      assert Boards.list_invites(other_scope) == [other_invite]
    end

    test "get_invite!/2 returns the invite with given id" do
      scope = user_scope_fixture()
      invite = invite_fixture(scope)
      other_scope = user_scope_fixture()
      assert Boards.get_invite!(scope, invite.id) == invite
      assert_raise Ecto.NoResultsError, fn -> Boards.get_invite!(other_scope, invite.id) end
    end

    test "create_invite/3 with valid data creates a invite" do
      valid_attrs = %{name: "some name", expire_at: ~U[2025-10-01 09:25:00Z]}
      scope = user_scope_fixture()
      board = board_fixture(scope)

      assert {:ok, %Invite{} = invite} = Boards.create_invite(scope, board, valid_attrs)
      assert invite.name == "some name"
      assert invite.expire_at == ~U[2025-10-01 09:25:00Z]
      assert invite.user_id == scope.user.id
    end

    test "create_invite/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      board = board_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Boards.create_invite(scope, board, @invalid_attrs)
    end

    test "update_invite/3 with valid data updates the invite" do
      scope = user_scope_fixture()
      invite = invite_fixture(scope)
      update_attrs = %{name: "some updated name", expire_at: ~U[2025-10-02 09:25:00Z]}

      assert {:ok, %Invite{} = invite} = Boards.update_invite(scope, invite, update_attrs)
      assert invite.name == "some updated name"
      assert invite.expire_at == ~U[2025-10-02 09:25:00Z]
    end

    test "update_invite/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      invite = invite_fixture(scope)

      assert_raise MatchError, fn ->
        Boards.update_invite(other_scope, invite, %{})
      end
    end

    test "update_invite/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      invite = invite_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Boards.update_invite(scope, invite, @invalid_attrs)
      assert invite == Boards.get_invite!(scope, invite.id)
    end

    test "delete_invite/2 deletes the invite" do
      scope = user_scope_fixture()
      invite = invite_fixture(scope)
      assert {:ok, %Invite{}} = Boards.delete_invite(scope, invite)
      assert_raise Ecto.NoResultsError, fn -> Boards.get_invite!(scope, invite.id) end
    end

    test "delete_invite/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      invite = invite_fixture(scope)
      assert_raise MatchError, fn -> Boards.delete_invite(other_scope, invite) end
    end

    test "change_invite/2 returns a invite changeset" do
      scope = user_scope_fixture()
      invite = invite_fixture(scope)
      assert %Ecto.Changeset{} = Boards.change_invite(scope, invite)
    end
  end
end
