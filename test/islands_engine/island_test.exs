defmodule IslandsEngine.IslandTest do
  use ExUnit.Case
  doctest IslandsEngine.Island

  alias IslandsEngine.{Island, Coordinate}

  test "creates an island with l_shape" do
    {:ok, coordinate} = Coordinate.new(4, 6)

    assert Island.new(:l_shape, coordinate) ==
             {:ok,
              %Island{
                hit_coordinates: MapSet.new(),
                coordinates:
                  MapSet.new([
                    %Coordinate{col: 6, row: 4},
                    %Coordinate{col: 6, row: 5},
                    %Coordinate{col: 6, row: 6},
                    %Coordinate{col: 7, row: 6}
                  ])
              }}
  end

  test "should not allow unknown type" do
    {:ok, coordinate} = Coordinate.new(4, 6)
    assert Island.new(:wrong, coordinate) == {:error, :invalid_island_type}
  end

  test "should not allow shape coordinates outside of board" do
    {:ok, coordinate} = Coordinate.new(10, 10)
    assert Island.new(:l_shape, coordinate) == {:error, :invalid_coordinate}
  end

  test "overlaps? works correctly" do
    {:ok, square_coordinate} = Coordinate.new(1, 1)
    {:ok, square} = Island.new(:square, square_coordinate)

    {:ok, dot_coordinate} = Coordinate.new(1, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:ok, l_shape_coordinate} = Coordinate.new(5, 5)
    {:ok, l_shape} = Island.new(:l_shape, l_shape_coordinate)

    assert Island.overlaps?(square, dot) == true
    assert Island.overlaps?(square, l_shape) == false
    assert Island.overlaps?(dot, l_shape) == false
  end

  test "guesses work correctly" do
    {:ok, dot_coordinate} = Coordinate.new(4, 4)
    {:ok, dot} = Island.new(:dot, dot_coordinate)

    {:ok, coordinate} = Coordinate.new(2, 2)
    assert Island.guess(dot, coordinate) == :miss
    assert Enum.empty?(dot.hit_coordinates)

    {:ok, hit_coordinate} = Coordinate.new(4, 4)
    {:hit, dot} = Island.guess(dot, hit_coordinate)

    assert dot.hit_coordinates == MapSet.new([%Coordinate{col: 4, row: 4}])
  end
end
