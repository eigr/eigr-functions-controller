defmodule Eigr.FunctionsController.Server.GrpcEndpoint do
  @moduledoc false
  use GRPC.Endpoint

  intercept(GRPC.Logger.Server)
  intercept(GRPCPrometheus.ServerInterceptor)

  services = [
    Eigr.FunctionsController.Server.OperatorService
  ]

  run(services)
end
