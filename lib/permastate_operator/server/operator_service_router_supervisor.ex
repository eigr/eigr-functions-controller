defmodule PermastateOperator.Server.OperatorServiceRouter.Supervisor do
  @moduledoc false
  use DynamicSupervisor

  def start_link(_opts),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)

  def add_stream_to_supervisor(app_id, stream) do
    child_spec = %{
      id: PermastateOperator.Server.OperatorServiceRouter,
      start: {PermastateOperator.Server.OperatorServiceRouter, :star_link, [{app_id, stream}]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end
end
