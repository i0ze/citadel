defmodule Citadel.BoardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Citadel.Boards` context.
  """

  @doc """
  Generate a board.
  """
  def board_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name"
      })

    {:ok, board} = Citadel.Boards.create_board(scope, attrs)
    Citadel.Repo.preload(board, [:memberships, :user])
  end

  @doc """
  Generate a sticker.
  """
  def sticker_fixture(scope, attrs \\ %{}) do
    board = board_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        text: "some text",
        x: 42,
        y: 42
      })

    {:ok, sticker} = Citadel.Boards.create_sticker(scope, board, attrs)
    sticker
  end

  @doc """
  Generate a membership.
  """
  def membership_fixture(scope, attrs \\ %{}) do
    board_id = attrs[:board_id] || board_fixture(scope).id

    attrs =
      Enum.into(attrs, %{
        role: "some role"
      })

    {:ok, membership} = Citadel.Boards.create_membership(scope, board_id, attrs)
    membership
  end

  @doc """
  Generate a invite.
  """
  def invite_fixture(scope, attrs \\ %{}) do
    board = board_fixture(scope)

    attrs =
      Enum.into(attrs, %{
        expire_at: ~N[2025-10-01 09:25:00],
        name: "some name"
      })

    {:ok, invite} = Citadel.Boards.create_invite(scope, board, attrs)
    invite
  end
end
