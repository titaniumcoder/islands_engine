defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case
  doctest IslandsEngine.Coordinate

  alias IslandsEngine.Coordinate

  test "creates valid coordinate" do
    assert Coordinate.new(1, 1) == {:ok, %Coordinate{row: 1, col: 1}}
  end

  test "does not allow invalid rows" do
    assert Coordinate.new(-1, 1) == {:error, :invalid_coordinate}
    assert Coordinate.new(11, 1) == {:error, :invalid_coordinate}
  end

  test "does not allow invalid columns" do
    assert Coordinate.new(1, -1) == {:error, :invalid_coordinate}
    assert Coordinate.new(1, 11) == {:error, :invalid_coordinate}
  end
end
