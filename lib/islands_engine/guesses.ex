defmodule IslandsEngine.Guesses do
  alias IslandsEngine.Coordinate

  @type t() :: %__MODULE__{hits: MapSet.t(Coordinate.t()), misses: MapSet.t(Coordinate.t())}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @spec new() :: t()
  def new(), do: %__MODULE__{hits: MapSet.new(), misses: MapSet.new()}

  @spec add(t(), :hit | :miss, Coordinate.t()) :: t()
  def add(%__MODULE__{} = guesses, :hit, %Coordinate{} = coordinate),
    do: update_in(guesses.hits, &MapSet.put(&1, coordinate))

  def add(%__MODULE__{} = guesses, :miss, %Coordinate{} = coordinate),
    do: update_in(guesses.misses, &MapSet.put(&1, coordinate))
end
