defmodule CitadelWeb.BoardsLive.InviteBoard do
  alias Citadel.{Boards, Accounts}
  use CitadelWeb, :live_view

  def mount(%{"hash" => hash}, session, socket) do
    invite = Citadel.Boards.get_invite_by_hash(hash)

    {current_user, _} = Accounts.get_user_by_session_token(session["user_token"])
    scope = Accounts.Scope.for_user(current_user)

    Boards.create_membership(scope, invite.board_id, %{role: "viewer"})

    socket =
      socket
      |> put_flash(:info, "Вы успешно приглашены!")
      |> push_navigate(to: ~p"/boards/#{invite.board_id}")

    {:ok, socket}
  end
end
