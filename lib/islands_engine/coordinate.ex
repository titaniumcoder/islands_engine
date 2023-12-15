defmodule IslandsEngine.Coordinate do
  @type t() :: %__MODULE__{row: pos_integer(), col: pos_integer()}

  @board_range 1..10

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @spec new(pos_integer(), pos_integer()) :: {:ok, t()} | {:error, :invalid_coordinate}
  def new(row, col) when row in @board_range and col in @board_range,
    do: {:ok, %__MODULE__{row: row, col: col}}

  def new(_row, _col), do: {:error, :invalid_coordinate}
end
