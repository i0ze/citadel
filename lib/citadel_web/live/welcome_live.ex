defmodule CitadelWeb.WelcomeLive do
  use CitadelWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    socket = assign(socket, current_time: Time.utc_now() |> Time.to_string())
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Current time is {@current_time}</h1>
    """
  end

  def handle_info(:tick, socket) do
    socket = assign(socket, current_time: Time.utc_now() |> Time.to_string())
    {:noreply, socket}
  end
end
