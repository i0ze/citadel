defmodule CitadelWeb.Hooks.UserAuth do
  alias Citadel.Accounts
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:ensure_board_access, %{"id" => board_id}, session, socket) do
    {current_user, _} = Accounts.get_user_by_session_token(session["user_token"])
    scope = Accounts.Scope.for_user(current_user)

    case Citadel.Boards.get_board(scope, board_id) do
      {:ok, board} ->
        socket =
          socket
          |> assign(:current_user, current_user)
          |> assign(:scope, scope)
          |> assign(:board, board)

        # <--- :cont означает "продолжай"
        {:cont, socket}

      {:error, _reason} ->
        # Доступ запрещен. Останавливаем mount и делаем редирект.
        socket =
          socket
          |> put_flash(:error, "Board not found or access denied.")
          |> redirect(to: "/boards")

        # <--- :halt означает "СТОП! Немедленно остановись и выполни редирект"
        {:halt, socket}
    end
  end
end
