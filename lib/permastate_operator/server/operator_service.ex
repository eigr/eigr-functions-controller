defmodule PermastateOperator.Server.OperatorService do
  @moduledoc """
  gRPC OperatorService
  """

  use GRPC.Server,
    service: Io.Eigr.Permastate.Operator.OperatorService.Service,
    compressors: [GRPC.Compressor.Gzip]

  require Logger

  def handle_events(_events, _stream) do
  end
end
