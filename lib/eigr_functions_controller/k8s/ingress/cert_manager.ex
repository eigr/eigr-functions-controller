defmodule Eigr.FunctionsController.K8S.Ingress.CertManager do
  def get_cert_manager_params(tls_params) do
    %{"cert-manager.io/cluster-issuer" => tls_params["certManager"]["clusterIssuer"]}
  end
end
