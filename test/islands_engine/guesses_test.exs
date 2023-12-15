defmodule IslandsEngine.GuessesTest do
  use ExUnit.Case
  doctest IslandsEngine.Guesses

  alias IslandsEngine.Coordinate
  alias IslandsEngine.Guesses

  test "add guess that hits" do
    {:ok, coordinate1} = Coordinate.new(8, 3)
    {:ok, coordinate2} = Coordinate.new(9, 7)
    {:ok, coordinate3} = Coordinate.new(1, 2)

    guesses =
      Guesses.new()
      |> Guesses.add(:hit, coordinate1)
      |> Guesses.add(:hit, coordinate2)
      |> Guesses.add(:miss, coordinate3)

    assert guesses == %Guesses{
             hits: MapSet.new([%Coordinate{row: 8, col: 3}, %Coordinate{row: 9, col: 7}]),
             misses: MapSet.new([%Coordinate{row: 1, col: 2}])
           }
  end
end
