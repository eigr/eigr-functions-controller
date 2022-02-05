defmodule Eigr.FunctionsController.Controllers.V1.Function do
  @moduledoc """
   Eigr.FunctionsController.Controllers.V1.Function: Function CRD.

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
    runtime: grpc # Optional. Default grpc. Currently only one `grpc` runtime is provided, in the future we will support webassembly/wasm runtimes
    features:
      eventing: false # Optional. Default is false.
      eventingMappings:
        sources:
          - name: shopping-cart-source
            serviceName: ShoppingCart
            rpcMethodName: AddItem
            type: kafka
            config:
              url: kafka:9092
              topic: shopping-cart-in-events
              groupId: shopping-cart-group
              credentials:
                secrets: kafka-credentials-secret
                # If the credentials are stored in a secret, the username and password are not needed.
                username: kafka-user # Use only in local development
                password: kafka-password # Use only in local development
        sinks:
          - name: shopping-cart-sink
            serviceName: ShoppingCart
            rpcMethodName: AddItem
            type: rabbitmq
            config:
              url: rabbitmq:9092
              topic: shopping-cart-out-events
              credentials:
                secrets: rabbitmq-credentials-secret
                # If the credentials are stored in a secret, the username and password are not needed.
                username: rabbitmq-user # Use only in local development
                password: rabbitmq-password # Use only in local development
      typeMappings: false # Optional. Default is false.
      typeMappingsKeys:
        - typeName: AddLineItem
          persistentKey: user_id
        - typeName: RemoveLineItem
          persistentKey: user_id
        - typeName: GetShoppingCart
          persistentKey: user_id
      httpTranscode: true # Optional. Default is false.
      httpTranscodeMappings:
        - serviceName: ShoppingCart
          rpcMethodName: AddItem
          path: /cart/{user_id}/items/add
          method: POST
          body: "*"
        - serviceName: ShoppingCart
          rpcMethodName: RemoveItem
          path: /cart/{user_id}/items/{product_id}
          method: DELETE
        - serviceName: ShoppingCart
          rpcMethodName: GetCart
          path: /cart/{user_id}
          method: GET
          additionalBindings:
            - path: /cart/{user_id}/items
              method: GET
              responseBody: "items"
    expose:
      method: ingress # Optional. Default is none. Supported values are: ingress, nodeport, loadbalancer
      ingress:
        className: nginx
        host: shopping-cart.eigr.io # Mandatory
        path: / # Optional. Default is /
        use-tls: true # Optional. Default is false
        tls:
          secretName: shopping-cart-tls # Mandatory if "use-tls" is true. Name of the secret containing the TLS certificate. Defaults to the eigr-functions-tls
          #cert-manager:
          #  cluster-issuer: eigr-functions-cluster-issuer # Mandatory
          #  common-name: shopping-cart.eigr.io # Optional. Default is none
          #  duration: 2h # Optional. Default is none
          #  renew-before: 1h # Optional. Default is none
          #  usages: # Optional. Default is none
          #    - "digital signature"
          #    - "key encipherment"
          #    - "server auth"
          #  http01-ingress-class: nginx-ingress-controller # Optional. Default is none
          #  http01-edit-in-place: "true" # Optional. Default is none
      #loadBalancer: # Optional. Default is none.
      #  port: 8080
      #  targetPort: 9000
      #nodePort: # Optional. Default is none. Use this only in development.
      #  port: 8080
      #  targetPort: 9000
      #  nodePort: 30001
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
    portBindings: # Optional
      type: grpc # uds, grpc
      port: 8080 # 8080
      socketPath: /var/run/eigr/functions.sock # Optional. Default is none. Only used if type is uds
  ```
  """

  require Logger
  use Bonny.Controller

  alias Eigr.FunctionsController.K8S.Controller, as: K8SController

  @group "functions.eigr.io"

  @version "v1"

  @rule {"apps", ["deployments"], ["*"]}
  @rule {"autoscaling", ["horizontalpodautoscalers"], ["*"]}
  @rule {"networking.k8s.io", ["ingresses"], ["*"]}
  @rule {"", ["services", "pods", "configmaps"], ["*"]}

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

  @additional_printer_columns [
    %{
      name: "runtime",
      type: "string",
      description: "Runtime for function execution",
      JSONPath: ".spec.backend.runtime"
    },
    %{
      name: "language",
      type: "string",
      description: "User function language",
      JSONPath: ".spec.backend.language"
    },
    %{
      name: "expose method",
      type: "string",
      description: "Method used to expose function",
      JSONPath: ".spec.backend.expose.method"
    },
    %{
      name: "http transcode",
      type: "boolean",
      description: "Whether HTTP transcode is enabled",
      JSONPath: ".spec.backend.features.httpTranscode"
    },
    %{
      name: "eventing",
      type: "boolean",
      description: "Whether the function is eventing enabled",
      JSONPath: ".spec.backend.features.eventing"
    }
  ]

  @doc """
  Called periodically for each existing CustomResource to allow for reconciliation.
  """
  @spec reconcile(map()) :: :ok | :error
  @impl Bonny.Controller
  def reconcile(payload) do
    track_event(:reconcile, payload)
    :ok
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
         {:ok, _} <- K8s.Client.create(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.create(resources.autoscaler) |> run() do
      resource_res = K8s.Client.create(resources.deployment) |> run()

      case K8s.Client.create(resources.cluster_service) |> run() do
        {:ok, _} ->
          Logger.info("Cluster service created")

        {:error, err} ->
          Logger.warn(
            "Failure creating cluster service: #{inspect(err)}. Probably already exists."
          )
      end

      result =
        case resource_res do
          {:ok, _} ->
            case resources.expose_service do
              {:ingress, definition} ->
                K8s.Client.create(definition) |> run()

              {:load_balancer, definition} ->
                Logger.warn(
                  "Using LoadBalancer is extremely discouraged. Instead try using the Ingress method"
                )

                K8s.Client.create(definition) |> run()

              {:node_port, definition} ->
                Logger.warn(
                  "Using NodePort is extremely discouraged. Instead try using the Ingress method"
                )

                K8s.Client.create(definition) |> run()

              {:none, _} ->
                {:ok, nil}
            end

          {:error, error} ->
            {:error, error}
        end

      case result do
        {:ok, _} ->
          Logger.info(
            "User function #{resources.name} has been successfully deployed to namespace #{resources.namespace}"
          )

          :ok

        {:error, error} ->
          Logger.error(
            "One or more resources of user function #{resources.name} failed during deployment. Error: #{inspect(error)}"
          )

          {:error, error}
      end
    else
      {:error, error} ->
        Logger.error(
          "One or more resources of user function #{resources.name} failed during deployment. Error: #{inspect(error)}"
        )

        {:error, error}
    end
  end

  @doc """
  Updates `deployment`, `service` and `configmap` resources.
  """
  @spec modify(map()) :: :ok | :error
  @impl Bonny.Controller
  def modify(payload) do
    resources = K8SController.get_function_manifests(payload)

    with {:ok, _} <- K8s.Client.delete(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.create(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.cluster_service) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.autoscaler) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.configmap) |> run() do
      resource_res = K8s.Client.patch(resources.deployment) |> run()

      result =
        case resource_res do
          {:ok, _} ->
            case resources.expose_service do
              {:ingress, definition} ->
                K8s.Client.patch(definition) |> run()

              {:load_balancer, definition} ->
                Logger.warn(
                  "Using LoadBalancer is extremely discouraged. Instead try using the Ingress method"
                )

                K8s.Client.patch(definition) |> run()

              {:node_port, definition} ->
                Logger.warn(
                  "Using NodePort is extremely discouraged. Instead try using the Ingress method"
                )

                K8s.Client.patch(definition) |> run()

              {:none, _} ->
                {:ok, nil}
            end

          {:error, error} ->
            {:error, error}
        end

      case result do
        {:ok, _} ->
          Logger.info(
            "User function #{resources.name} has been successfully updated to namespace #{resources.namespace}"
          )

          :ok

        {:error, error} ->
          Logger.error(
            "One or more resources of user function #{resources.name} failed during updating. Error: #{inspect(error)}"
          )

          {:error, error}
      end
    else
      {:error, error} ->
        Logger.error(
          "One or more resources of user function #{resources.name} failed during updating. Error: #{inspect(error)}"
        )

        {:error, error}
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
         {:ok, _} <- K8s.Client.delete(resources.autoscaler) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.configmap) |> run() do
      resource_res = K8s.Client.delete(resources.deployment) |> run()

      result =
        case resource_res do
          {:ok, _} ->
            case resources.expose_service do
              {:ingress, definition} ->
                K8s.Client.delete(definition) |> run()

              {:load_balancer, definition} ->
                K8s.Client.delete(definition) |> run()

              {:node_port, definition} ->
                K8s.Client.delete(definition) |> run()

              {:none, _} ->
                {:ok, nil}
            end
        end

      case result do
        {:ok, _} ->
          Logger.info(
            "All resources for user function #{resources.name} have been successfully deleted from namespace #{resources.namespace}"
          )

          :ok

        {:error, error} ->
          Logger.error(
            "One or more resources of the user role #{resources.name} failed during its removal. Error: #{inspect(error)}"
          )

          {:error, error}
      end
    else
      {:error, error} ->
        Logger.error(
          "One or more resources of the user role #{resources.name} failed during its removal. Error: #{inspect(error)}"
        )

        {:error, error}
    end
  end

  defp run(%K8s.Operation{} = op),
    do: K8s.Client.run(op, Bonny.Config.cluster_name())

  defp track_event(type, resource),
    do: Logger.info("#{type}: #{inspect(resource)}")
end
