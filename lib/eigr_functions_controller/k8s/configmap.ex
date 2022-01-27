defmodule Eigr.FunctionsController.K8S.ConfigMap do
  @behaviour Eigr.FunctionsController.K8S.Manifest

  @impl true
  def manifest(ns, name, params), do: gen_configmap(ns, name)

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
end
