defmodule IslandsEngine.Game do
  @moduledoc """
  Manages the state of the game itself.
  """

  use GenServer, restart: :transient

  alias IslandsEngine.Board
  alias IslandsEngine.Coordinate
  alias IslandsEngine.Guesses
  alias IslandsEngine.Island
  alias IslandsEngine.Rules

  @players [:player1, :player2]
  @timeout 15_000

  #### Client API ####
  @spec start_link(String.t()) :: GenServer.on_start()
  def start_link(name) when is_binary(name),
    do: GenServer.start_link(__MODULE__, name, name: via_tuple(name))

  @spec via_tuple(String.t()) :: {:via, Registry, {Registry.Game, String.t()}}
  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}

  @spec add_player(pid(), String.t()) :: :ok
  def add_player(game, name) when is_binary(name), do: GenServer.call(game, {:add_player, name})

  @spec position_island(pid(), Rules.players(), Island.shapes(), pos_integer(), pos_integer()) ::
          :ok | :error | {:error, :invalid_coordinate} | {:error, :invalid_island_type}
  def position_island(game, player, key, row, col) when player in @players,
    do: GenServer.call(game, {:position_island, player, key, row, col})

  @spec set_islands(pid(), Rules.players()) ::
          :ok | :error | {:error, :not_all_islands_positioned}
  def set_islands(game, player) when player in @players,
    do: GenServer.call(game, {:set_islands, player})

  @spec guess_coordinate(pid(), Rules.players(), pos_integer(), pos_integer()) :: any()
  def guess_coordinate(game, player, row, col) when player in @players,
    do: GenServer.call(game, {:guess_coordinate, player, row, col})

  #### Server API ####
  @impl GenServer
  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: Rules.new()}, @timeout}
  end

  @impl GenServer
  def handle_call({:add_player, name}, _from, state) do
    case Rules.check(state.rules, :add_player) do
      {:ok, rules} ->
        state
        |> update_player2_name(name)
        |> update_rules(rules)
        |> reply_success(:ok)

      :error ->
        {:replay, :error, state}
    end
  end

  @impl GenServer
  def handle_call({:position_island, player, key, row, col}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:position_islands, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {:ok, island} <- Island.new(key, coordinate),
         %{} = board <- Board.position_island(board, key, island) do
      state
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state}
      {:error, :invalid_coordinate} -> {:reply, {:error, :invalid_coordinate}, state}
      {:error, :invalid_island_type} -> {:reply, {:error, :invalid_island_type}, state}
      {:error, :overlapping_island} -> {:reply, {:error, :overlapping_island}, state}
    end
  end

  @impl GenServer
  def handle_call({:set_islands, player}, _from, state) do
    board = player_board(state, player)

    with {:ok, rules} <- Rules.check(state.rules, {:set_islands, player}),
         true <- Board.all_island_positioned?(board) do
      state
      |> update_rules(rules)
      |> reply_success({:ok, board})
    else
      :error -> {:reply, :error, state}
      false -> {:reply, {:error, :not_all_islands_positioned}, state}
    end
  end

  @impl GenServer
  def handle_call({:guess_coordinate, player, row, col}, _from, state) do
    opponent = opponent(player)
    opponent_board = player_board(state, opponent)

    with {:ok, rules} <- Rules.check(state.rules, {:guess_coordinate, player}),
         {:ok, coordinate} <- Coordinate.new(row, col),
         {hit_or_miss, forested_island, win_status, opponent_board} <-
           Board.guess(opponent_board, coordinate),
         {:ok, rules} <- Rules.check(rules, {:win_check, win_status}) do
      state
      |> update_board(opponent, opponent_board)
      |> update_guesses(player, hit_or_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, forested_island, win_status})
    else
      :error -> {:reply, :error, state}
      {:error, :invalid_coordinate} -> {:reply, {:error, :invalid_coordinate}, state}
    end
  end

  #### Helper Functions ####
  defp update_player2_name(state, name), do: put_in(state.player2.name, name)

  defp update_rules(state, rules), do: %{state | rules: rules}

  defp update_board(state, player, board),
    do: Map.update!(state, player, fn player -> %{player | board: board} end)

  defp update_guesses(state, player, hit_or_miss, coordinate) do
    update_in(state[player].guesses, fn guesses ->
      Guesses.add(guesses, hit_or_miss, coordinate)
    end)
  end

  defp reply_success(state, reply), do: {:reply, reply, state, @timeout}

  defp player_board(state, player), do: Map.get(state, player).board

  defp opponent(:player1), do: :player2
  defp opponent(:player2), do: :player1
end
