defmodule IslandsEngine.GameTest do
  use ExUnit.Case
  doctest IslandsEngine.Game
  alias IslandsEngine.Game

  setup do
    {:ok, game} = start_supervised({Game, "Frank"})
    %{game: game}
  end

  describe "add_player/2" do
    test "will allow to add players", %{game: game} do
      Game.add_player(game, "Dweezil")
      state_data = :sys.get_state(game)
      assert state_data.player2.name == "Dweezil"
    end
  end

  describe "position_island/5" do
    setup %{game: game} do
      Game.add_player(game, "Wilma")
      state_data = :sys.get_state(game)
      assert state_data.rules.state == :players_set

      %{game: game}
    end

    test "handles position island", %{game: game} do
      Game.position_island(game, :player1, :square, 1, 1)
      state_data = :sys.get_state(game)
      assert Map.has_key?(state_data.player1.board, :square)
    end

    test "cannot position illegal island", %{game: game} do
      assert Game.position_island(game, :player1, :dot, 12, 1) == {:error, :invalid_coordinate}
    end

    test "cannot position unknown key", %{game: game} do
      assert Game.position_island(game, :player1, :wrong, 1, 1) == {:error, :invalid_island_type}
    end

    test "cannot position island out of board", %{game: game} do
      assert Game.position_island(game, :player1, :l_shape, 10, 10) ==
               {:error, :invalid_coordinate}
    end
  end
end
