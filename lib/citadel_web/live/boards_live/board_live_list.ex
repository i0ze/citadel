defmodule CitadelWeb.BoardsLive.BoardLiveList do
  alias Citadel.Accounts
  alias Citadel.Boards
  use CitadelWeb, :live_view

  def mount(_params, session, socket) do
    {current_user, _} = Accounts.get_user_by_session_token(session["user_token"])
    user_scope = Accounts.Scope.for_user(current_user)

    boards =
      Boards.list_boards(user_scope)
      |> Enum.reverse()

    socket = assign(socket, :boards, boards)
    Boards.subscribe_boards(user_scope)
    {:ok, socket}
  end

  def handle_info({:created, board}, socket) do
    updated_boards = [board | socket.assigns.boards]
    socket = assign(socket, :boards, updated_boards)

    {:noreply, socket}
  end
end
