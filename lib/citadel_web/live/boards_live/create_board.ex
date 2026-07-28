defmodule CitadelWeb.BoardsLive.CreateBoard do
  alias Citadel.Boards.Board
  alias Citadel.Boards
  use CitadelWeb, :live_view
  alias Citadel.Accounts

  def mount(_params, session, socket) do
    {current_user, _} = Accounts.get_user_by_session_token(session["user_token"])
    scope = Accounts.Scope.for_user(current_user)
    board = Board.changeset(%Board{}, %{name: ""}, scope)

    socket =
      socket
      |> assign(:scope, scope)
      |> assign(:form, to_form(board))

    {:ok, socket}
  end

  def handle_event("create_board", %{"board" => params}, socket) do
    {:ok, board} = Boards.create_board(socket.assigns.scope, params)

    socket =
      socket
      |> put_flash(:info, "Board created successfully!")
      |> push_navigate(to: ~p"/boards/#{board.id}")

    {:noreply, socket}
  end
end
