defmodule PermastateOperator.Server.OperatorService do
  @moduledoc """
  gRPC OperatorService
  """
  use GRPC.Server,
    service: Io.Eigr.Permastate.Operator.OperatorService.Service,
    compressors: [GRPC.Compressor.Gzip]

  require Logger

  alias PermastateOperator.Server.OperatorServiceRouter
  alias PermastateOperator.Server.OperatorServiceRouter.Supervisor, as: OperatorServiceSupervisor

  def handle_events(events, stream) do
    Stream.each(events, fn event ->
      act_on_event_info(event, stream)
    end)
    |> Stream.run()
  end

  def act_on_event_info({:login, data} = _event, stream) do
    {:ok, _pid} = OperatorServiceSupervisor.add_stream_to_supervisor(data.id, stream)
  end

  def act_on_event_info({:logout, data} = _event, _stream) do
    OperatorServiceRouter.logout(data.id)
  end

  def act_on_event_info({:apply, _}, _stream) do
  end
end
