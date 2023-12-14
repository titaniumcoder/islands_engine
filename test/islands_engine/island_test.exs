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
end
