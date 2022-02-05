defmodule Eigr.FunctionsController.K8S.Ingress.Nginx do
  @behaviour Eigr.FunctionsController.K8S.Ingress.Controller

  def get_class(%{"className" => "nginx"}), do: "nginx"

  def get_path_type(%{"className" => "nginx"}), do: "Prefix"

  def get_annotations(params) do
    status = params["useTls"] == "true"

    if status do
      tls_params = params["tls"]
      cluster_issuer = tls_params["certManager"]["clusterIssuer"]

      case cluster_issuer do
        "none" -> {:nothing, params}
        _ -> {:ok, get_cert_manager_params(tls_params)}
      end
    else
      {:nothing, params}
    end
  end

  def get_tls_secret(params) do
    host = params["host"]
    status = params["useTls"]
    IO.inspect(host)
    IO.inspect(status)

    if status do
      IO.inspect("status true")
      secretName = params["tls"]["secretName"]

      {:ok,
       %{
         "secretName" => "#{secretName}",
         "hosts" => ["#{host}"]
       }}
    else
      IO.inspect("status false")
      {:nothing, params}
    end
  end

  defp get_cert_manager_params(tls_params) do
    %{"cert-manager.io/cluster-issuer" => tls_params["certManager"]["clusterIssuer"]}
  end
end
