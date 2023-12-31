defmodule IslandsEngine.Board do
  @moduledoc """
  Managing the board with all it islands.
  """
  alias IslandsEngine.Coordinate
  alias IslandsEngine.Island

  @type shapes() :: Island.shapes()
  @type t() :: %{shapes() => Island.t()}

  @spec new() :: t()
  def new(), do: %{}

  @spec position_island(t(), shapes(), Island.t()) :: {:error, :overlapping_island} | t()
  def position_island(board, key, %Island{} = island) do
    if overlaps_existing_island?(board, key, island) do
      {:error, :overlapping_island}
    else
      Map.put(board, key, island)
    end
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end

  @spec all_island_positioned?(t()) :: boolean()
  def all_island_positioned?(board), do: Enum.all?(Island.types(), &Map.has_key?(board, &1))

  @spec guess(t(), Coordinate.t()) :: {:hit | :miss, shapes() | :none, :win | :no_win, t()}
  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end

  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  defp forest_check(board, key) do
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  defp forested?(board, key) do
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  defp win_check(board) do
    if all_forested?(board) do
      :win
    else
      :no_win
    end
  end

  defp all_forested?(board),
    do: Enum.all?(board, fn {_key, island} -> Island.forested?(island) end)
end
