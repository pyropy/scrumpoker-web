defmodule ScrumpokerwebWeb.PageLive do
  use ScrumpokerwebWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("create_new", _data, socket) do
    game_id = Scrumpoker.IdGenerator.generate()
    {:noreply, redirect(socket, to: "/game/#{game_id}")}
  end
end
