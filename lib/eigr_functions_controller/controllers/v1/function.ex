defmodule Eigr.FunctionsController.Controllers.V1.Function do
  @moduledoc """
   Eigr.FunctionsController: Function CRD.

  ## Kubernetes CRD Spec
  Eigr Function CRD

  ### Examples
  ```yaml
  ---
  apiVersion: functions.eigr.io/v1
  kind: Function
  metadata:
  name: shopping-cart # Mandatory. Name of the function
  # The namespace where the role will be deployed to the cluster.
  # All proxies deployed in a given namespace form a cluster, that is, they are visible to each other.
  # Proxies that exist in other namespaces are invisible to those in this namespace
  namespace: default # Optional. Default namespace is "default"
  spec:
  backend:
    image: cloudstateio/cloudstate-python-tck:latest # Mandatory
    language: python # Optional. Default is none.This parameter is only used to define the defaults resource limits of a user container.
    autoscaler: # Optional
      strategy: hpa # Optional. For now, only hpa is supported
      minReplicas: 1 # Optional. Default is 1
      maxReplicas: 100 # Optional. Default is 100
      averageCpuUtilizationPercentage: 80 # Optional. Default is 80
      averageMemoryUtilizationValue: 100Mi # Optional. Default is 100Mi
    resources: # Optional
      requests:
        cpu: 100m
        memory: 100Mi
      limits:
        cpu: 100m
        memory: 100Mi
    runtime: grpc # Optional. Default grpc. Currently only one `grpc` runtime is provided, in the future we will support webassembly/wasm runtimes
    portBindings: # Optional
      type: http # uds, grpc
      port: 8080 # 8080, /var/run/eigr/functions.sock
  ```
  """

  require Logger
  use Bonny.Controller

  alias Eigr.FunctionsController.K8S.Controller, as: K8SController

  # It would be possible to call @group "functions.eigr.io"
  # However, to maintain compatibility with the original protocol, we will call it cloudstate.io
  @group "functions.eigr.io"

  @version "v1"

  @rule {"apps", ["deployments"], ["*"]}
  @rule {"autoscaling", ["horizontalpodautoscaler"], ["*"]}
  @rule {"", ["services", "pods", "configmaps", "horizontalpodautoscaler"], ["*"]}

  @scope :cluster
  @names %{
    plural: "functions",
    singular: "function",
    kind: "Function",
    shortNames: [
      "f",
      "fs",
      "fc",
      "fcs",
      "func",
      "function",
      "funcs",
      "functions"
    ]
  }

  # @additional_printer_columns [
  #  %{
  #    name: "test",
  #    type: "string",
  #    description: "test",
  #    JSONPath: ".spec.test"
  #  }
  # ]

  @doc """
  Called periodically for each existing CustomResource to allow for reconciliation.
  """
  @spec reconcile(map()) :: :ok | :error
  @impl Bonny.Controller
  def reconcile(payload) do
    track_event(:reconcile, payload)
    modify(payload)
  end

  @doc """
  Creates a kubernetes `deployment`, `service` and `configmap` that runs a "Eigr" app.
  """
  @spec add(map()) :: :ok | :error
  @impl Bonny.Controller
  def add(payload) do
    track_event(:add, payload)
    resources = K8SController.get_function_manifests(payload)

    with {:ok, _} <- K8s.Client.create(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.create(resources.cluster_service) |> run(),
         {:ok, _} <- K8s.Client.create(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.create(resources.deployment) |> run() do
      resource_res = K8s.Client.create(resources.autoscaler) |> run()
      Logger.info("service result: #{inspect(resource_res)}")

      case resource_res do
        {:ok, _} -> :ok
        {:error, error} -> {:error, error}
      end
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Updates `deployment`, `service` and `configmap` resources.
  """
  @spec modify(map()) :: :ok | :error
  @impl Bonny.Controller
  def modify(payload) do
    resources = K8SController.get_function_manifests(payload)

    with {:ok, _} <- K8s.Client.patch(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.cluster_service) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.deployment) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.autoscaler) |> run() do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Deletes `deployment`, `service` and `configmap` resources.
  """
  @spec delete(map()) :: :ok | :error
  @impl Bonny.Controller
  def delete(payload) do
    track_event(:delete, payload)
    resources = K8SController.get_function_manifests(payload)

    with {:ok, _} <- K8s.Client.delete(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.cluster_service) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.deployment) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.autoscaler) |> run() do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  defp run(%K8s.Operation{} = op),
    do: K8s.Client.run(op, Bonny.Config.cluster_name())

  defp track_event(type, resource),
    do: Logger.info("#{type}: #{inspect(resource)}")
end
