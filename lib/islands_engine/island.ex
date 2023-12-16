defmodule IslandsEngine.Island do
  @moduledoc """
  Manages the state of an island.
  """
  alias IslandsEngine.Coordinate
  alias IslandsEngine.Island

  @type shapes() :: [:atoll | :dot | :l_shape | :s_shape | :square]
  @type t() :: %__MODULE__{
          coordinates: MapSet.t(Coordinate.t()),
          hit_coordinates: MapSet.t(Coordinate.t())
        }

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  @spec new(shapes(), Coordinate.t()) ::
          {:ok, t()} | {:error, :invalid_coordinate} | {:error, :invalid_island_type}
  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    end
  end

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot), do: [{0, 0}]
  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(_), do: {:error, :invalid_island_type}

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} ->
        {:cont, MapSet.put(coordinates, coordinate)}

      {:error, :invalid_coordinate} ->
        {:halt, {:error, :invalid_coordinate}}
    end
  end

  @spec overlaps?(t(), t()) :: boolean()
  def overlaps?(existing_island, new_island),
    do: not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)

  @spec guess(t(), Coordinate.t()) :: {:hit, t()} | :miss
  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  @spec forested?(t()) :: boolean()
  def forested?(island), do: MapSet.equal?(island.coordinates, island.hit_coordinates)

  @spec types() :: shapes()
  def types(), do: [:atoll, :dot, :l_shape, :s_shape, :square]
end
