defmodule Eigr.FunctionsController.K8S.Deployment do
  @behaviour Eigr.FunctionsController.K8S.Manifest

  import Eigr.FunctionsController.K8S.Limits

  @impl true
  def manifest(ns, name, params), do: gen_deployment(ns, name, params)

  defp gen_deployment(ns, name, params) do
    image = Map.get(params, "image")
    language = Map.get(params, "language")
    replicas = Map.get(params, "autoscaler") |> Map.get("minReplicas")
    port = Map.get(params, "portBinding") |> Map.get("port")
    resources = Map.get(params, "resources") |> get_limits(language)
    _port_binding_type = Map.get(params, "portBinding") |> Map.get("type")

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
            "labels" => %{
              "app" => name,
              "cluster-name" => "proxy",
              "functions.eigr.io/language" => language,
              "functions.eigr.io/controller.version" =>
                "#{to_string(Application.spec(:eigr_functions_controller, :vsn))}"
            }
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => "massa-proxy",
                "image" => "#{resolve_proxy_image()}",
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
                    "configMapRef" => %{"name" => "#{name}-sidecar-cm"}
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

  defp resolve_proxy_image(),
    do:
      Application.get_env(
        :eigr_functions_controller,
        :proxy_image,
        "docker.io/eigr/massa-proxy:0.1.31"
      )
end
