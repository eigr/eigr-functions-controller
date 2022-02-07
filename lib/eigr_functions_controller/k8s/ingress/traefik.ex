defmodule Eigr.FunctionsController.K8S.Ingress.Traefik do
  @behaviour Eigr.FunctionsController.K8S.Ingress.Controller

  alias Eigr.FunctionsController.K8S.Ingress.{CertManager, Tls}

  def get_class(%{"className" => "traefik"}), do: "traefik"

  def get_path_type(_params), do: "ImplementationSpecific"

  def get_annotations(params) do
    annotations = %{}
    status = params["useTls"]

    if status do
      tls_params = params["tls"]
      cluster_issuer = tls_params["certManager"]["clusterIssuer"]

      case cluster_issuer do
        "none" ->
          {:nothing, params}

        _ ->
          {:ok, Map.merge(annotations, CertManager.get_cert_manager_params(tls_params))}
      end
    else
      {:nothing, params}
    end
  end

  def get_tls_secret(params), do: Tls.get_secret(params)
end
