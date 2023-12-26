defmodule IslandsEngine.GameTest do
  use ExUnit.Case
  doctest IslandsEngine.Game

  alias IslandsEngine.Game
  alias IslandsEngine.Rules

  setup do
    {:ok, game} = start_supervised({Game, "Frank-" <> :crypto.strong_rand_bytes(100)})
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

    test "cannot position islands once playing", %{game: game} do
      :sys.replace_state(game, fn state_data ->
        %{state_data | rules: %Rules{state: :player1_turn}}
      end)

      assert Game.position_island(game, :player1, :dot, 5, 5) == :error
    end
  end

  describe "set_islands/2" do
    setup %{game: game} do
      Game.add_player(game, "Wilma")
    end

    test "cannot continue without all islands positioned", %{game: game} do
      assert Game.set_islands(game, :player1) == {:error, :not_all_islands_positioned}
    end

    test "can continue once islands are set", %{game: game} do
      Game.position_island(game, :player1, :atoll, 1, 1)
      Game.position_island(game, :player1, :dot, 1, 4)
      Game.position_island(game, :player1, :l_shape, 1, 5)
      Game.position_island(game, :player1, :s_shape, 5, 1)
      Game.position_island(game, :player1, :square, 5, 5)

      {:ok, %{s_shape: _, l_shape: _, atoll: _, dot: _, square: _}} =
        Game.set_islands(game, :player1)
    end
  end

  describe "guess_coordinate/4" do
    setup %{game: game} do
      Game.add_player(game, "Trane")
      Game.position_island(game, :player1, :dot, 1, 1)
      Game.position_island(game, :player2, :square, 1, 1)

      # and along comes the test cheater
      :sys.replace_state(game, fn data ->
        %{data | rules: %Rules{state: :player1_turn}}
      end)

      %{game: game}
    end

    test "can guess a miss", %{game: game} do
      assert Game.guess_coordinate(game, :player1, 5, 5) == {:miss, :none, :no_win}
    end

    test "can't guess if it's not his round", %{game: game} do
      assert Game.guess_coordinate(game, :player2, 5, 5) == :error
    end

    test "hit's the game winner", %{game: game} do
      Game.guess_coordinate(game, :player1, 5, 5)
      assert Game.guess_coordinate(game, :player2, 1, 1) == {:hit, :dot, :win}
    end
  end
end
