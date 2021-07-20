defmodule PermastateOperator.Server.OperatorServiceRouter do
  @moduledoc """
  Inter process communication for handle gRPC Streams
  """
  use GenServer
  require Logger
  alias GRPC.Server
  alias PermastateOperator.Server.OperatorServiceRouter.Supervisor, as: OperatorServiceSupervisor

  @impl true
  def init({id, %{payload: %{pid: ref}}} = stream) do
    Process.monitor(ref)
    Process.flag(:trap_exit, true)

    {:ok, %{id: id, stream: stream}}
  end

  @impl true
  def handle_cast({:create_resource, event}, %{stream: stream} = state) do
    Server.send_reply(stream, event)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete_resource, event}, %{stream: stream} = state) do
    Server.send_reply(stream, event)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:modify_resource, event}, %{stream: stream} = state) do
    Server.send_reply(stream, event)
    {:noreply, state}
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

  def login(session, stream) do
    {:ok, _pid} = OperatorServiceSupervisor.add_stream_to_supervisor(session.app_id, stream)
    :ok
  end

  def logout(session), do: GenServer.cast(via(session.app_id), :logout)

  def create(session, event),
    do: GenServer.cast(via(session.app_id), {:create_resource, event})

  def delete(session, event),
    do: GenServer.cast(via(session.app_id), {:delete_resource, event})

  def modify(session, event),
    do: GenServer.cast(via(session.app_id), {:modify_resource, event})

  defp via(id), do: {:via, Registry, {PermastateOperator.Registry, id}}
end
