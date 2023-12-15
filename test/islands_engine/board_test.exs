defmodule IslandsEngine.BoardTest do
  use ExUnit.Case
  doctest IslandsEngine.Board

  alias IslandsEngine.{Island, Coordinate, Board}

  test "check board functionality as a whole" do
    board = Board.new()

    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    board = Board.position_island(board, :square, square)

    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    assert Board.position_island(board, :dot, dot) == {:error, :overlapping_island}

    {:ok, new_dot_coordinate} = Coordinate.new(3, 3)
    {:ok, dot} = Island.new(:dot, new_dot_coordinate)

    board = Board.position_island(board, :dot, dot)

    {:ok, guess_coordinate} = Coordinate.new(10, 10)
    assert {:miss, :none, :no_win, board} = Board.guess(board, guess_coordinate)

    {:ok, hit_coordinate} = Coordinate.new(1, 1)
    assert {:hit, :none, :no_win, board} = Board.guess(board, hit_coordinate)

    # Cheating for the win...
    square = %{square | hit_coordinates: square.coordinates}
    board = Board.position_island(board, :square, square)

    {:ok, win_coordinate} = Coordinate.new(3, 3)
    assert {:hit, :dot, :win, _board} = Board.guess(board, win_coordinate)
  end
end
