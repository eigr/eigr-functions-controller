defmodule Eigr.FunctionsController.K8S.Ingress.Ambassador do
  @behaviour Eigr.FunctionsController.K8S.Ingress.Controller

  def get_class(%{"className" => "ambassador"}), do: "ambassador"

  def get_path_type(_params) do
  end

  def get_annotations(params) do
    status = params["useTls"]

    if status do
      tls_params = params["tls"]
      cluster_issuer = tls_params["certManager"]["clusterIssuer"]

      case cluster_issuer do
        "none" ->
          {:nothing, params}

        _ ->
          {:ok, get_cert_manager_params(tls_params)}
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

  defp get_cert_manager_params(tls_params) do
    %{"cert-manager.io/cluster-issuer" => tls_params["certManager"]["clusterIssuer"]}
  end
end
