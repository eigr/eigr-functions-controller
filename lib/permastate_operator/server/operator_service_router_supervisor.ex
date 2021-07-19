defmodule PermastateOperator.Server.OperatorServiceRouter.Supervisor do
  @moduledoc false
  use DynamicSupervisor

  def start_link(_opts),
    do: DynamicSupervisor.init(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)

  def create(session_id, stream) do
    case DynamicSupervisor.start_child(__MODULE__, %{
           id: PermastateOperator.Server.OperatorServiceRouter,
           start: {PermastateOperator.Server.OperatorServiceRouter, :star_link, [{id, stream}]},
           restart: :transient
         }) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end
end
