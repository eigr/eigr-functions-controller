defmodule PermastateOperator do
  @moduledoc """
  Documentation for `PermastateOperator`.
  """
  use Application

  @grpc_server %{
    id: GRPC.Server.Supervisor,
    start:
      {GRPC.Server.Supervisor, :start_link, [{PermastateOperator.Server.GrpcEndpoint, 9080}]},
    type: :supervisor
  }

  def start(_type, _args) do
    children = [
      @grpc_server,
      PermastateOperator.Controller.V1.Action,
      PermastateOperator.Controller.V1.StatefulServices
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
