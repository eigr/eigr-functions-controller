defmodule Eigr.FunctionsController.K8S.HeadlessService do
  @behaviour Eigr.FunctionsController.K8S.Manifest

  @impl true
  def manifest(ns, name, _params),
    do: %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "annotations" => %{
          "functions.eigr.io/controller.version" =>
            "#{to_string(Application.spec(:eigr_functions_controller, :vsn))}"
        },
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
