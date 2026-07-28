defmodule CitadelWeb.CounterLive do
  use CitadelWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, count: 0)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="text-center">
      <h1 class="text-4xl font-bold">Counter: {@count}</h1>
      <button phx-click="decrement" class="px-4 py-2 mt-4 text-white bg-red-500 rounded">-</button>
      <button phx-click="increment" class="px-4 py-2 mt-4 text-white bg-green-500 rounded">+</button>
    </div>
    """
  end

  def handle_event("increment", _params, socket) do
    new_count = socket.assigns.count + 1
    socket = assign(socket, count: new_count)

    {:noreply, socket}
  end

  def handle_event("decrement", _params, socket) do
    new_count = socket.assigns.count - 1
    socket = assign(socket, count: new_count)

    {:noreply, socket}
  end
end
