defmodule IslandsEngine.GameTest do
  use ExUnit.Case
  doctest IslandsEngine.Game
  alias IslandsEngine.Game

  setup do
    {:ok, game} = start_supervised({Game, "Frank"})
    %{game: game}
  end

  test "will allow to add players", %{game: game} do
    Game.add_player(game, "Dweezil")
    state_data = :sys.get_state(game)
    assert state_data.player2.name == "Dweezil"
  end
end
