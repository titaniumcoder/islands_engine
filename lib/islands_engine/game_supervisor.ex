defmodule IslandsEngine.GameSupervisor do
  @moduledoc false
  use DynamicSupervisor

  alias IslandsEngine.Game

  def start_link(init_args),
    do: DynamicSupervisor.start_link(__MODULE__, init_args, name: __MODULE__)

  def start_game(name), do: DynamicSupervisor.start_child(__MODULE__, {Game, name})

  def stop_game(name) do
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  @impl DynamicSupervisor
  def init(args) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: args)
  end

  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
end
