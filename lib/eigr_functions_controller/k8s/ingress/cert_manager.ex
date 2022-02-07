defmodule Eigr.FunctionsController.K8S.Ingress.CertManager do
  @spec get_cert_manager_params(map) :: map()
  def get_cert_manager_params(tls_params) do
    opts = [
      get_cn(tls_params),
      get_usages(tls_params),
      get_issuer(tls_params),
      get_duration(tls_params),
      get_temp_cert(tls_params),
      get_renew_before(tls_params),
      get_ingress_class(tls_params),
      get_edit_in_place(tls_params)
    ]

    Enum.reduce(opts, fn elem, acc -> Map.merge(acc, elem) end)
  end

  defp get_cn(%{"certManager" => %{"certManager" => "none"}} = _tls_param), do: %{}

  defp get_cn(%{"certManager" => %{"certManager" => cn}} = _tls_param),
    do: %{"cert-manager.io/common-name" => cn}

  defp get_issuer(tls_params),
    do: %{"cert-manager.io/cluster-issuer" => tls_params["certManager"]["clusterIssuer"]}

  defp get_usages(%{"certManager" => %{"usages" => []}} = _tls_param), do: %{}

  defp get_usages(%{"certManager" => %{"usages" => usages}} = _tls_param)
       when is_list(usages) and length(usages) > 0,
       do: %{"cert-manager.io/usages" => Enum.join(usages, ",")}

  defp get_renew_before(%{"certManager" => %{"renewBefore" => "none"}} = _tls_param), do: %{}

  defp get_renew_before(%{"certManager" => %{"renewBefore" => renew_value}} = _tls_param),
    do: %{"cert-manager.io/renew-before" => renew_value}

  defp get_duration(%{"certManager" => %{"duration" => "none"}} = _tls_param), do: %{}

  defp get_duration(%{"certManager" => %{"duration" => duration_value}} = _tls_param),
    do: %{"cert-manager.io/duration" => duration_value}

  defp get_edit_in_place(%{"certManager" => %{"http01EditInplace" => "false"}} = _tls_param),
    do: %{}

  defp get_edit_in_place(%{"certManager" => %{"http01EditInplace" => "true"}} = _tls_param),
    do: %{"acme.cert-manager.io/http01-edit-in-place" => "true"}

  defp get_ingress_class(%{"certManager" => %{"http01IngressClass" => "none"}} = _tls_param),
    do: %{}

  defp get_ingress_class(%{"certManager" => %{"http01IngressClass" => value}} = _tls_param),
    do: %{"acme.cert-manager.io/http01-edit-in-place" => value}

  defp get_temp_cert(%{"certManager" => %{"temporaryCertificate" => "false"}} = _tls_param),
    do: %{}

  defp get_temp_cert(%{"certManager" => %{"temporaryCertificate" => "true"}} = _tls_param),
    do: %{"manager.io/issue-temporary-certificate" => "true"}
end
