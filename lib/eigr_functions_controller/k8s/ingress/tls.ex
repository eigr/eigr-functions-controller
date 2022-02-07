defmodule Eigr.FunctionsController.K8S.Ingress.Tls do
  def get_secret(params) do
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
