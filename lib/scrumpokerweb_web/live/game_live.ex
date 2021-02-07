defmodule ScrumpokerwebWeb.GameLive do
  use ScrumpokerwebWeb, :live_view

  alias Scrumpoker.{GameServer, Player, IdGenerator}

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    DynamicSupervisor.start_child(Scrumpoker.GameSupervisor, {GameServer, name: via_tuple(game_id), id: game_id})
    :ok = Phoenix.PubSub.subscribe(Scrumpokerweb.PubSub, game_id)
    {:ok, assign_game(socket, game_id, nil)}
  end

  defp via_tuple(game_id) do
    {:via, Registry, {Scrumpoker.GameRegistry, game_id}}
  end

  defp assign_game(socket, game_id, player) do
    socket
    |> assign(game_id: game_id, player: player)
    |> assign_game()
  end

defp assign_game(socket, %Player{} = player) do
    socket
    |> assign(player: player)
    |> assign_game()
  end

  defp assign_game(%{assigns: %{game_id: game_id}} = socket) do
    game = GenServer.call(via_tuple(game_id), :game_state)
    assign(socket, game: game)
  end

  @impl true
  def handle_event("vote", %{"vote" => vote_value}, %{assigns: %{game_id: game_id, player: player}} = socket) do
    GameServer.player_vote(game_id, player, vote_value)
    :ok = Phoenix.PubSub.broadcast(Scrumpokerweb.PubSub, game_id, :update)
    {:noreply, assign_game(socket)}
  end

  @impl true
  def handle_event("player_join", %{"name" => name}, %{assigns: %{game_id: game_id}} = socket) do
    id = IdGenerator.generate()
    player = %Player{id: id, name: name}
    GameServer.player_join(game_id, player)
    :ok = Phoenix.PubSub.broadcast(Scrumpokerweb.PubSub, game_id, :update)
    {:noreply, assign_game(socket, player)}
  end

  @impl true
  def handle_info(:update, socket) do
    {:noreply, assign_game(socket)}
  end
end
