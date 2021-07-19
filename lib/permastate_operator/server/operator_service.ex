defmodule PermastateOperator.Server.OperatorService do
  @moduledoc """
  gRPC OperatorService
  """

  use GRPC.Server,
    service: Io.Eigr.Permastate.Operator.OperatorService.Service,
    compressors: [GRPC.Compressor.Gzip]

  alias PermastateOperator.Server.OperatorServiceRouter.Supervisor, as: OperatorServiceSupervisor

  require Logger

  def handle_events(_events, _stream) do
  end
end
