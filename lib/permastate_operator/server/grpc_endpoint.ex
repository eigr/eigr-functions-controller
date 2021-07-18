defmodule PermastateOperator.Server.GrpcEndpoint do
  @moduledoc false
  use GRPC.Endpoint

  intercept(GRPC.Logger.Server)
  intercept(GRPCPrometheus.ServerInterceptor)

  services = [
    PermastateOperator.Server.OperatorService
  ]

  run(services)
end
