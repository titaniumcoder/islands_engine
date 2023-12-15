defmodule IslandsEngine.RulesTest do
  use ExUnit.Case
  doctest IslandsEngine.Rules

  alias IslandsEngine.Rules

  test "adding player works" do
    rules = Rules.new()
    {:ok, rules} = Rules.check(rules, :add_player)

    assert rules.state == :players_set
  end

  test "illegal state is not working" do
    rules = Rules.new()
    :error = Rules.check(rules, :completely_wrong_action)

    assert rules.state == :initialized
  end

  test "should transfer to players set" do
    rules = Rules.new()
    rules = %{rules | state: :players_set}
    assert rules.state == :players_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set
  end

  test "should set islands" do
    rules = Rules.new()
    rules = %{rules | state: :players_set}

    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_not_set

    assert Rules.check(rules, {:position_islands, :player1}) == :error

    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules.state == :players_set
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_not_set

    {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert rules.state == :player1_turn
    assert rules.player1 == :islands_set
    assert rules.player2 == :islands_set

    assert Rules.check(rules, {:set_islands, :player2}) == :error
  end

  test "only player 1 can play if it's his turn" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}

    assert Rules.check(rules, {:guess_coordinate, :player2}) == :error

    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert rules.state == :player2_turn
  end

  test "only player 2 can play if it's his turn" do
    rules = Rules.new()
    rules = %{rules | state: :player2_turn}

    assert Rules.check(rules, {:guess_coordinate, :player1}) == :error

    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
    assert rules.state == :player1_turn
  end

  test "player1 didn't win so it stays his turn" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}

    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert rules.state == :player1_turn
  end

  test "player2 didn't win so it stays his turn" do
    rules = Rules.new()
    rules = %{rules | state: :player2_turn}

    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert rules.state == :player2_turn
  end

  test "player1 did win, game over" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}

    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over
  end

  test "player2 did win, game over" do
    rules = Rules.new()
    rules = %{rules | state: :player2_turn}

    {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over
  end
end
