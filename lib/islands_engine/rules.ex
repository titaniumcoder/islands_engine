defmodule IslandsEngine.Rules do
  @moduledoc """
  FSM for the game.
  """

  @type states() ::
          :initialized | :players_set | :islands_set | :player1_turn | :player2_turn | :game_over
  @type player_states() :: :islands_not_set | :islands_set
  @type players() :: :player1 | :player2
  @type t() :: %__MODULE__{state: states(), player1: player_states(), player2: player_states()}

  defstruct state: :initialized, player1: :islands_not_set, player2: :islands_not_set

  @spec new() :: t()
  def new(), do: %__MODULE__{}

  @spec check(
          t(),
          :add_player
          | {:set_islands, players()}
          | {:position_islands, players()}
          | {:guess_coordinate, players()}
          | {:win_check, :win | :no_win}
        ) :: {:ok, t()} | :error
  def check(%__MODULE__{state: :initialized} = rules, :add_player),
    do: {:ok, %__MODULE__{rules | state: :players_set}}

  def check(%__MODULE__{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)

    if both_player_islands_set?(rules) do
      {:ok, %__MODULE__{rules | state: :player1_turn}}
    else
      {:ok, rules}
    end
  end

  def check(%__MODULE__{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%__MODULE__{state: :player1_turn} = rules, {:guess_coordinate, :player1}),
    do: {:ok, %__MODULE__{rules | state: :player2_turn}}

  def check(%__MODULE__{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %__MODULE__{rules | state: :game_over}}
    end
  end

  def check(%__MODULE__{state: :player2_turn} = rules, {:guess_coordinate, :player2}),
    do: {:ok, %__MODULE__{rules | state: :player1_turn}}

  def check(%__MODULE__{state: :player2_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %__MODULE__{rules | state: :game_over}}
    end
  end

  def check(_state, _action), do: :error

  defp both_player_islands_set?(rules),
    do: rules.player1 == :islands_set and rules.player2 == :islands_set
end
