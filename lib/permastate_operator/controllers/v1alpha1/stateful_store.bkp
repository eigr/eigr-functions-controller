defmodule PermastateOperator.Controller.V1alpha1.StatefulStore do
  @moduledoc """
  PermastateOperator: StatefulStore CRD.

  ## Kubernetes CRD Spec
  Cloudstate StatefulStore CRD

  ### Examples
  ```
  apiVersion: cloudstate.io/v1alpha1
  kind: StatefulStore
  metadata:
    name: my-postgres-store
  spec:
    type: Postgres
    deployment: Unmanaged
    config:
      service: postgresql.default.svc.cluster.local
      credentialsFromSecret:
        name: postgres-credentials
  ```
  """

  require Logger
  use Bonny.Controller

  @version "v1alpha1"

  @rule {"apps", ["deployments"], ["*"]}
  @rule {"", ["services", "pods", "configmap", "secrets"], ["*"]}

  # It would be possible to call @group "permastate.eigr.io"
  # However, to maintain compatibility with the original protocol, we will call it cloudstate.io
  @group "cloudstate.io"

  @scope :namespaced
  @names %{
    plural: "StatefulStores",
    singular: "StatefulStore",
    kind: "StatefulStore",
    shortNames: ["stst"]
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
    :ok
  end

  @doc """
  Creates a kubernetes `statefulset`, `service` and `configmap` that runs a "Cloudstate" app.
  """
  @spec add(map()) :: :ok | :error
  @impl Bonny.Controller
  def add(payload) do
    track_event(:add, payload)
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.create(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.create(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Updates `statefulset`, `service` and `configmap` resources.
  """
  @spec modify(map()) :: :ok | :error
  @impl Bonny.Controller
  def modify(payload) do
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.patch(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.patch(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Deletes `statefulset`, `service` and `configmap` resources.
  """
  @spec delete(map()) :: :ok | :error
  @impl Bonny.Controller
  def delete(payload) do
    track_event(:delete, payload)
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.delete(resources.deployment) |> run,
         {:ok, _} <- K8s.Client.delete(resources.service) |> run do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  defp parse(%{
         "metadata" => %{"name" => name, "namespace" => ns},
         "spec" => %{"greeting" => greeting}
       }) do
    deployment = gen_deployment(ns, name, greeting)
    service = gen_service(ns, name, greeting)

    %{
      deployment: deployment,
      service: service
    }
  end

  defp gen_service(ns, name, _greeting) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "name" => name,
        "namespace" => ns,
        "labels" => %{"app" => name}
      },
      "spec" => %{
        "ports" => [%{"port" => 5000, "protocol" => "TCP"}],
        "selector" => %{"app" => name},
        "type" => "NodePort"
      }
    }
  end

  defp gen_deployment(ns, name, greeting) do
    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => %{
        "name" => name,
        "namespace" => ns,
        "labels" => %{"app" => name}
      },
      "spec" => %{
        "replicas" => 2,
        "selector" => %{
          "matchLabels" => %{"app" => name}
        },
        "template" => %{
          "metadata" => %{
            "labels" => %{"app" => name}
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => name,
                "image" => "quay.io/coryodaniel/greeting-server",
                "env" => [%{"name" => "GREETING", "value" => greeting}],
                "ports" => [%{"containerPort" => 5000}]
              }
            ]
          }
        }
      }
    }
  end

  defp run(%K8s.Operation{} = op),
    do: K8s.Client.run(op, Bonny.Config.cluster_name())

  defp track_event(type, resource),
    do: Logger.info("#{type}: #{inspect(resource)}")
end
