defmodule PermastateOperator.Controller.V1.StatefulStore do
  @moduledoc """
  PermastateOperator: StatefulStore CRD.

  ## Kubernetes CRD Spec
  Cloudstate StatefulStore CRD

  ### Examples
  ```
  apiVersion: functions.eigr.io/v1
  kind: StatefulStore
  metadata:
    name: my-postgres-store
  spec:
    type: Postgres
    deployment: Unmanaged
    config:
      service: postgresql.default.svc.cluster.local
      credentialsFromSecret:
        name: postgres-credentials
  ```
  """

  require Logger
  use Bonny.Controller

  @version "v1"

  @rule {"apps", ["deployments"], ["*"]}
  @rule {"", ["services", "pods", "configmap", "secrets"], ["*"]}

  # It would be possible to call @group "functions.eigr.io"
  @group "functions.eigr.io"

  @scope :namespaced
  @names %{
    plural: "StatefulStores",
    singular: "StatefulStore",
    kind: "StatefulStore",
    shortNames: ["stst"]
  }

  # @additional_printer_columns [
  #  %{
  #    name: "test",
  #    type: "string",
  #    description: "test",
  #    JSONPath: ".spec.test"
  #  }
  # ]
end
