defmodule CitadelWeb.BoardsLive.BoardLive do
  alias Citadel.Boards.Invite
  alias Citadel.Token
  use CitadelWeb, :live_view
  alias Citadel.Boards
  alias Citadel.Boards.Sticker

  on_mount {CitadelWeb.Hooks.UserAuth, :ensure_board_access}

  def mount(_params, _session, socket) do
    board = socket.assigns.board
    scope = socket.assigns.scope

    role =
      cond do
        board.user_id == scope.user.id ->
          :owner
        membership = Enum.find(board.memberships, &(&1.user_id == scope.user.id)) ->
          String.to_atom(membership.role)
        true ->
          :viewer
      end

    socket =
      socket
      |> assign(:editing_sticker_id, nil)
      |> assign(:role, role)

    Boards.subscribe_to_board(board)
    Boards.subscribe_invites(board.id)

    {:ok, socket}
  end

  def handle_event("add_sticker", _params, socket) do
    Boards.create_sticker(socket.assigns.scope, socket.assigns.board, %{
      text: "hello!",
      x: 50,
      y: 50
    })

    {:noreply, socket}
  end

  def handle_event("move_sticker", %{"id" => sticker_id_str, "x" => x, "y" => y}, socket) do
    sticker_id = String.to_integer(sticker_id_str)
    sticker = socket.assigns.board.stickers[sticker_id]
    Boards.update_sticker(socket.assigns.scope, sticker, %{x: x, y: y})

    {:noreply, socket}
  end

  def handle_event("edit_sticker", %{"id" => sticker_id_str}, socket) do
    sticker_id = String.to_integer(sticker_id_str)

    sticker = socket.assigns.board.stickers[sticker_id]
    changeset = Sticker.changeset(sticker, %{}, socket.assigns.scope)

    socket =
      socket
      |> assign(:editing_sticker_id, sticker_id)
      |> assign(:form, to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("validate_sticker", %{"sticker" => sticker_params}, socket) do
    sticker_id = socket.assigns.editing_sticker_id
    sticker = socket.assigns.board.stickers[sticker_id]

    changeset = Sticker.changeset(sticker, sticker_params, socket.assigns.scope)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save_sticker", %{"sticker" => sticker_params}, socket) do
    scope = socket.assigns.scope
    sticker_id = socket.assigns.editing_sticker_id
    sticker = socket.assigns.board.stickers[sticker_id]

    case Boards.update_sticker(scope, sticker, sticker_params) do
      {:ok, _updated_sticker} ->
        # Успех! Сбрасываем режим редактирования
        socket = assign(socket, :editing_sticker_id, nil)
        {:noreply, socket}

      {:error, changeset} ->
        # Ошибка валидации, обновляем форму
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete_sticker", %{"id" => sticker_id_str}, socket) do
    sticker_id = String.to_integer(sticker_id_str)
    sticker = socket.assigns.board.stickers[sticker_id]
    Boards.delete_sticker(socket.assigns.scope, sticker)

    {:noreply, socket}
  end

  def handle_event("generate_invite", _params, socket) do
    attrs = %{name: Token.generate(), expire_at: ~U[2025-12-12 00:00:00Z]}
    Boards.create_invite(socket.assigns.scope, socket.assigns.board, attrs)

    {:noreply, socket}
  end

  def handle_info({:created, %Sticker{} = sticker}, socket) do
    socket =
      update(socket, :board, fn board ->
        put_in(board.stickers[sticker.id], sticker)
      end)

    {:noreply, socket}
  end

  def handle_info({:updated, %Sticker{} = sticker}, socket) do
    socket =
      update(socket, :board, fn board ->
        put_in(board.stickers[sticker.id], sticker)
      end)

    {:noreply, socket}
  end

  def handle_info({:deleted, %Sticker{} = sticker}, socket) do
    socket =
      update(socket, :board, fn board ->
        %{board | stickers: Map.delete(board.stickers, sticker.id)}
      end)

    {:noreply, socket}
  end

  def handle_info({:created, %Invite{} = invite}, socket) do
    socket =
      update(socket, :board, fn board ->
        put_in(board.invites[invite.id], invite)
      end)

    {:noreply, socket}
  end
end
