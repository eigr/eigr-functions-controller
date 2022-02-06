defmodule Eigr.FunctionsController.K8S.Ingress.Nginx do
  @behaviour Eigr.FunctionsController.K8S.Ingress.Controller

  alias Eigr.FunctionsController.K8S.Ingress.CertManager

  def get_class(%{"className" => "nginx"}), do: "nginx"

  def get_path_type(%{"className" => "nginx"}), do: "Prefix"

  def get_annotations(params) do
    status = params["useTls"]

    if status do
      tls_params = params["tls"]
      cluster_issuer = tls_params["certManager"]["clusterIssuer"]

      case cluster_issuer do
        "none" ->
          {:nothing, params}

        _ ->
          {:ok, CertManager.get_cert_manager_params(tls_params)}
      end
    else
      {:nothing, params}
    end
  end

  def get_tls_secret(params) do
    host = params["host"]
    status = params["useTls"]

    if status do
      secretName = params["tls"]["secretName"]

      {:ok,
       %{
         "secretName" => "#{secretName}",
         "hosts" => ["#{host}"]
       }}
    else
      {:nothing, params}
    end
  end
end
