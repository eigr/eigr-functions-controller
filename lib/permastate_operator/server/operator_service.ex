defmodule PermastateOperator.Server.OperatorService do
  @moduledoc """
  gRPC OperatorService
  """
  use GRPC.Server,
    service: Io.Eigr.Permastate.Operator.OperatorService.Service,
    compressors: [GRPC.Compressor.Gzip]

  alias Io.Eigr.Permastate.Operator.Event
  alias PermastateOperator.Server.OperatorServiceRouter.Supervisor, as: OperatorServiceSupervisor

  require Logger

  alias PermastateOperator.Server.OperatorServiceRouter
  alias PermastateOperator.Server.OperatorServiceRouter.Supervisor, as: OperatorServiceSupervisor

  @spec handle_events(Event.t(), GRPC.Server.Stream.t()) :: Event.t()
  def handle_events(events, stream) do
    Stream.each(events, fn event ->
      act_on_event_info(event, stream)
    end)
    |> Stream.run()
  end

  def act_on_event_info({:login, session} = _event, stream) do
    {:ok, _pid} = OperatorServiceSupervisor.add_stream_to_supervisor(session.app_id, stream)
  end

  def act_on_event_info({:logout, session} = _event, _stream) do
    OperatorServiceRouter.logout(session.app_id)
  end

  def act_on_event_info({:apply, _data}, _stream) do
  end
end
