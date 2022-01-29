defmodule Eigr.FunctionsController.K8S.Ingress do
  @behaviour Eigr.FunctionsController.K8S.Manifest

  @impl true
  def manifest(ns, name, params) do
    host = Map.get(params, "expose") |> Map.get("host")

    %{
      "apiVersion" => "networking.k8s.io/v1",
      "kind" => "Ingress",
      "metadata" => %{
        "labels" => %{
          "functions.eigr.io/controller.version" =>
            "#{to_string(Application.spec(:eigr_functions_controller, :vsn))}",
          "functions.eigr.io/wormhole.gate.earth.status" => "open"
        },
        "name" => "#{name}-ingress",
        "namespace" => ns
      },
      "spec" => %{
        "rules" => [
          %{
            "host" => host,
            "http" => %{
              "paths" => [
                %{
                  "backend" => %{
                    "service" => %{
                      "name" => "#{name}-svc",
                      "port" => %{
                        "name" => "proxy"
                      }
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  end
end
