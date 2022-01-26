defmodule Eigr.FunctionsController.Controllers.V1.Function do
  @moduledoc """
   Eigr.FunctionsController: Function CRD.

  ## Kubernetes CRD Spec
  Eigr Function CRD

  ### Examples
  ```yaml
  apiVersion: functions.eigr.io/v1
  kind: Function
  metadata:
    name: shopping-cart
  spec:
    backend:
      image: my-docker-hub-username/shopping-cart:latest
      portBindings:
        type: http
        port: 8080
        #type: uds
        #port: /var/run/shopping-cart.sock
  ```
  """

  require Logger
  use Bonny.Controller

  @port_binding_uds_default "/var/run/eigr/functions.sock"

  @default_params %{
    "language" => "none",
    "maxReplicas" => 100,
    "minReplicas" => 1,
    "portBinding" => %{"port" => 8080, "type" => "grpc"},
    "runtime" => "grpc",
    "resources" => %{
      "limits" => %{"cpu" => "100m", "memory" => "100Mi"},
      "requests" => %{"cpu" => "100m", "memory" => "100Mi"}
    }
  }

  @generic_lang_resources_limits %{
    "limits" => %{"cpu" => "500m", "memory" => "512Mi"},
    "requests" => %{"cpu" => "100m", "memory" => "100Mi"}
  }

  @go_lang_resources_limits %{
    "limits" => %{"cpu" => "500m", "memory" => "1024Mi"},
    "requests" => %{"cpu" => "200m", "memory" => "70Mi"}
  }

  @java_lang_resources_limits %{
    "limits" => %{"cpu" => "500m", "memory" => "2048Mi"},
    "requests" => %{"cpu" => "200m", "memory" => "100Mi"}
  }

  @python_lang_resources_limits %{
    "limits" => %{"cpu" => "500m", "memory" => "512Mi"},
    "requests" => %{"cpu" => "100m", "memory" => "70Mi"}
  }

  # It would be possible to call @group "functions.eigr.io"
  # However, to maintain compatibility with the original protocol, we will call it cloudstate.io
  @group "functions.eigr.io"

  @version "v1"

  @rule {"", ["services", "pods", "configmaps"], ["*"]}
  @rule {"apps", ["deployments"], ["*"]}

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
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.create(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.create(resources.cluster_service) |> run(),
         {:ok, _} <- K8s.Client.create(resources.configmap) |> run() do
      resource_res = K8s.Client.create(resources.deployment) |> run()
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
    resources = parse(payload)

    with {:ok, _} <- K8s.Client.patch(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.cluster_service) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.patch(resources.deployment) |> run() do
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

    with {:ok, _} <- K8s.Client.delete(resources.app_service) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.cluster_service) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.configmap) |> run(),
         {:ok, _} <- K8s.Client.delete(resources.deployment) |> run() do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  defp parse(%{
         "apiVersion" => "functions.eigr.io/v1",
         "kind" => "Function",
         "metadata" => %{
           "name" => name
         },
         "spec" => %{"backend" => backend}
       }) do
    backend_params = Map.merge(@default_params, backend)
    deployment = gen_deployment("default", name, backend_params)
    app_service = gen_app_service("default", name)
    cluster_service = gen_cluster_ns_service("default", name)
    configmap = gen_configmap("default", "proxy")

    %{
      configmap: configmap,
      deployment: deployment,
      app_service: app_service,
      cluster_service: cluster_service
    }
  end

  defp parse(%{
         "apiVersion" => "functions.eigr.io/v1",
         "kind" => "Function",
         "metadata" => %{
           "name" => name,
           "namespace" => ns
         },
         "spec" => %{"backend" => backend}
       }) do
    backend_params = Map.merge(@default_params, backend)
    deployment = gen_deployment(ns, name, backend_params)
    app_service = gen_app_service(ns, name)
    cluster_service = gen_cluster_ns_service(ns, name)
    configmap = gen_configmap(ns, "proxy")

    %{
      configmap: configmap,
      deployment: deployment,
      app_service: app_service,
      cluster_service: cluster_service
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

  defp gen_cluster_ns_service(ns, _name) do
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
          %{"port" => 4369, "name" => "epmd"}
        ]
      }
    }
  end

  defp gen_app_service(ns, name) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "name" => "#{name}-svc",
        "namespace" => ns
      },
      "spec" => %{
        "type" => "ClusterIP",
        "selector" => %{"app" => name},
        "ports" => [
          %{"name" => "proxy", "port" => 9000, "targetPort" => 9000},
          %{"name" => "http", "port" => 9001, "targetPort" => 9000}
        ]
      }
    }
  end

  defp get_limits(resources, "go"), do: Map.merge(@go_lang_resources_limits, resources)
  defp get_limits(resources, "java"), do: Map.merge(@java_lang_resources_limits, resources)
  defp get_limits(resources, "none"), do: Map.merge(@generic_lang_resources_limits, resources)
  defp get_limits(resources, "python"), do: Map.merge(@python_lang_resources_limits, resources)
  defp get_limits(resources, _), do: Map.merge(@generic_lang_resources_limits, resources)

  defp gen_deployment(ns, name, backend) do
    image = Map.get(backend, "image")
    language = Map.get(backend, "language")
    replicas = Map.get(backend, "minReplicas")
    port = Map.get(backend, "portBinding") |> Map.get("port")
    resources = Map.get(backend, "resources") |> get_limits(language)
    _port_binding_type = Map.get(backend, "portBinding") |> Map.get("type")

    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => %{
        "name" => name,
        "namespace" => ns,
        "labels" => %{"app" => name, "cluster-name" => "proxy"}
      },
      "spec" => %{
        "selector" => %{
          "matchLabels" => %{"app" => name, "cluster-name" => "proxy"}
        },
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
                "resources" => resources,
                "ports" => [
                  %{"containerPort" => port}
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
