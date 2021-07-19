defmodule PermastateOperator.Server.OperatorServiceRouter do
  @moduledoc """
  Inter process communication for handle gRPC Streams
  """
  use GenServer
  require Logger

  @impl true
  def init({id, %{payload: %{pid: ref}}} = stream) do
    Process.monitor(ref)
    Process.flag(:trap_exit, true)

    {:ok, %{id: id, stream: stream}}
  end

  @impl true
  def handle_cast(:logout, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:DOWN, _, _, _, reason}, %{id: id, stream: %{pid: ref}} = state) do
    Logger.warn("Stream closed with reason #{reason} for Session #{id}")
    Process.demonitor(ref)
    {:stop, :normal, state}
  end

  # Client API
  def start_link({id, _stream} = state) do
    GenServer.start_link(__MODULE__, state, via(id))
  end

  def logout(session_id), do: GenServer.cast(via(session_id), :logout)

  defp via(id), do: {:via, Registry, {PermastateOperator.Registry, id}}
end
