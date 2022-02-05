defmodule Eigr.FunctionsController.K8S.Ingress.Controller do
  @type params :: map()

  @type annotations :: map()

  @type class :: String.t()

  @callback get_class(params()) :: class()

  @callback get_path_type(params()) :: String.t()

  @callback get_annotations(params()) :: {:ok, annotations()} | {:nothing, params()}

  @callback get_tls_secret(params()) :: {:ok, map()} | {:nothing, params()}
end
