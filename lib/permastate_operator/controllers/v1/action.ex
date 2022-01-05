defmodule PermastateOperator.Controller.V1.Action do
  @moduledoc """
  PermastateOperator: Action CRD.

  ## Kubernetes CRD Spec
  Eigr Action CRD

  ### Examples
  ```
  apiVersion: functions.eigr.io/v1
  kind: Action
  metadata:
    name: shopping-cart
  spec:
    containers:
    - image: my-docker-hub-username/shopping-cart:latest
  ```
  """

  require Logger
  use Bonny.Controller

  @version "v1"

  @rule {"", ["services", "pods", "configmaps"], ["*"]}
  @rule {"apps", ["deployments"], ["*"]}

  # It would be possible to call @group "permastate.eigr.io"
  # However, to maintain compatibility with the original protocol, we will call it cloudstate.io
  @group "functions.eigr.io"

  @scope :namespaced
  @names %{
    plural: "actions",
    singular: "action",
    kind: "Action",
    shortNames: ["ac", "act", "action", "actions"]
  }

  # @additional_printer_columns [
  #  %{
  #    name: "test",
  #    type: "string",
  #    description: "test",
  #    JSONPath: ".spec.test"
  #  }
  # ]

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {Bonny.Controller, :start_link, [handler: __MODULE__]}
    }
  end

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
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.create(resources.service) |> run(),
         {:ok, _} <- K8s.Client.create(resources.configmap) |> run() do
      resource_res = K8s.Client.create(resources.statefulset) |> run()
      Logger.info("service result: #{inspect(resource_res)}")

      case resource_res do
        {:ok, _} -> :ok
        {:error, error} -> {:error, error}
        _ -> {:error}
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
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.patch(resources.service) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.statefulset) |> run() do
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
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.delete(resources.service) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.statefulset) |> run() do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  defp parse(%{
         "kind" => "Action",
         "apiVersion" => "functions.eigr.io/v1",
         "metadata" => %{"name" => name, "namespace" => ns},
         "spec" => %{"containers" => containers}
       }) do
    deployment = gen_deployment(ns, name, containers)
    service = gen_service(ns, name)
    configmap = gen_configmap(ns, "proxy")

    %{
      configmap: configmap,
      deployment: deployment,
      service: service
    }
  end

  defp gen_configmap(ns, name) do
    %{
      "apiVersion" => "v1",
      "kind" => "ConfigMap",
      "metadata" => %{
        "namespace" => ns,
        "name" => "proxy-cm"
      },
      "data" => %{
        "PROXY_APP_NAME" => name,
        "PROXY_CLUSTER_POLLING" => "3000",
        "PROXY_CLUSTER_STRATEGY" => "kubernetes-dns",
        "PROXY_HEADLESS_SERVICE" => "proxy-headless-svc",
        "PROXY_HEARTBEAT_INTERVAL" => "240000",
        "PROXY_HTTP_PORT" => "9001",
        "PROXY_PORT" => "9000",
        "PROXY_ROOT_TEMPLATE_PATH" => "/home/app",
        "PROXY_UDS_ADDRESS" => "/var/run/eigr/functions.sock",
        "PROXY_UDS_MODE" => "false",
        "USER_FUNCTION_HOST" => "127.0.0.1",
        "USER_FUNCTION_PORT" => "8080"
      }
    }
  end

  defp gen_service(ns, name) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "name" => "proxy-headless-svc",
        "namespace" => ns,
        "labels" => %{"svc-cluster-name" => "svc-proxy"}
      },
      "spec" => %{
        "clusterIP" => "None",
        "selector" => %{"cluster-name" => "proxy"},
        "ports" => [
          %{"port" => 4369, "name" => "epmd"},
          %{"port" => 9000, "name" => "proxy"},
          %{"port" => 9001, "name" => "http"}
        ]
      }
    }
  end

  defp gen_deployment(ns \\ "default", name, replicas \\ 1, containers) do
    container = List.first(containers)
    image = container["image"]

    %{
      "apiVersion" => "apps/v1",
      "kind" => "StatefulSet",
      "metadata" => %{
        "name" => name,
        "namespace" => ns,
        "labels" => %{"app" => name, "cluster-name" => "proxy"}
      },
      "spec" => %{
        "selector" => %{
          "matchLabels" => %{"app" => name, "cluster-name" => "proxy"}
        },
        "serviceName" => "proxy-headless-svc",
        "replicas" => replicas,
        "template" => %{
          "metadata" => %{
            "annotations" => %{
              "prometheus.io/port" => "9001",
              "prometheus.io/scrape" => "true"
            },
            "labels" => %{"app" => name, "cluster-name" => "proxy"}
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => "massa-proxy",
                "image" => "docker.io/eigr/massa-proxy:0.1.31",
                "env" => [
                  %{
                    "name" => "PROXY_POD_IP",
                    "value" => "6eycE1E/S341t4Bcto262ffyFWklCWHQIKloJDJYR7Y="
                  },
                  %{
                    "name" => "PROXY_POD_IP",
                    "valueFrom" => %{"fieldRef" => %{"fieldPath" => "status.podIP"}}
                  }
                ],
                "ports" => [
                  %{"containerPort" => 9000},
                  %{"containerPort" => 9001},
                  %{"containerPort" => 4369}
                ],
                "livenessProbe" => %{
                  "failureThreshold" => 10,
                  "httpGet" => %{
                    "path" => "/health",
                    "port" => 9001,
                    "scheme" => "HTTP"
                  },
                  "initialDelaySeconds" => 300,
                  "periodSeconds" => 3600,
                  "successThreshold" => 1,
                  "timeoutSeconds" => 1200
                },
                "resources" => %{
                  "limits" => %{
                    "memory" => "1024Mi"
                  },
                  "requests" => %{
                    "memory" => "70Mi"
                  }
                },
                "envFrom" => [
                  %{
                    "configMapRef" => %{"name" => "proxy-cm"}
                  }
                ]
              },
              %{
                "name" => "user-function",
                "image" => image,
                "ports" => [
                  %{"containerPort" => 8080}
                ]
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
