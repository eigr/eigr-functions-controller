defmodule Eigr.FunctionsController.K8S.Controller do
  @moduledoc false

  alias Eigr.FunctionsController.K8S.{
    ClusterIPService,
    ConfigMap,
    Deployment,
    HeadlessService,
    HPA,
    Ingress,
    StatefulSet
  }

  @port_binding_uds_default "/var/run/eigr/functions.sock"

  @default_params %{
    "autoscaler" => %{
      "strategy" => "hpa",
      "minReplicas" => 1,
      "maxReplicas" => 100,
      "averageCpuUtilizationPercentage" => 80,
      "averageMemoryUtilizationValue" => "100Mi"
    },
    "language" => "none",
    "portBinding" => %{"port" => 8080, "type" => "grpc"},
    "runtime" => "grpc",
    "resources" => %{
      "limits" => %{"cpu" => "100m", "memory" => "100Mi"},
      "requests" => %{"cpu" => "100m", "memory" => "100Mi"}
    }
  }

  def get_function_manifests(%{
        "apiVersion" => "functions.eigr.io/v1",
        "kind" => "Function",
        "metadata" => %{
          "name" => name
        },
        "spec" => %{"backend" => params}
      }) do
    backend_params = Map.merge(@default_params, params)

    %{
      configmap: ConfigMap.manifest("default", "proxy", backend_params),
      deployment: Deployment.manifest("default", name, backend_params),
      autoscaler: HPA.manifest("default", name, backend_params),
      app_service: ClusterIPService.manifest("default", name, backend_params),
      cluster_service: HeadlessService.manifest("default", name, backend_params)
    }
  end

  def get_function_manifests(%{
        "apiVersion" => "functions.eigr.io/v1",
        "kind" => "Function",
        "metadata" => %{
          "name" => name,
          "namespace" => ns
        },
        "spec" => %{"backend" => params}
      }) do
    backend_params = Map.merge(@default_params, params)

    %{
      configmap: ConfigMap.manifest(ns, "proxy", backend_params),
      deployment: Deployment.manifest(ns, name, backend_params),
      autoscaler: HPA.manifest(ns, name, backend_params),
      app_service: ClusterIPService.manifest(ns, name, backend_params),
      cluster_service: HeadlessService.manifest(ns, name, backend_params)
    }
  end
end
