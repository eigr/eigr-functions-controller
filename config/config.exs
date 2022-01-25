import Config

config :logger,
  backends: [:console],
  truncate: 65536,
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ]

# config :k8s,
#  clusters: %{
#    default: %{
#      conn: "~/.kube/config",
#      conf_opts: [context: "kind-default"]
#    }
#  }

config :bonny,
  # Add each CRD Controller module for this operator to load here
  controllers: [
    Eigr.FunctionsController.Controllers.V1.Function,
    Eigr.FunctionsController.Controllers.V1.PersistentFunction
  ],
  namespace: :all,

  #   # Set the Kubernetes API group for this operator.
  #   # This can be overwritten using the @group attribute of a controller
  #   group: "your-operator.example.com",

  #   # Name must only consist of only lowercase letters and hyphens.
  #   # Defaults to hyphenated mix app name
  operator_name: "eigr-functions-controller",

  #   # Name must only consist of only lowercase letters and hyphens.
  #   # Defaults to hyphenated mix app name
  #   service_account_name: "your-operator",

  #   # Labels to apply to the operator's resources.
  labels: %{
    cloudsate_protocol_minor_version: "1",
    cloudsate_protocol_major_version: "0",
    eigr_functions_protocol_minor_version: "1",
    eigr_functions_protocol_major_version: "0",
    proxy_name: "massa-proxy"
  },

  #   # Operator deployment resources. These are the defaults.
  resources: %{
    limits: %{cpu: "500m", memory: "1024Mi"},
    requests: %{cpu: "200m", memory: "200Mi"}
  }

#   # Defaults to "current-context" if a config file is provided, override user, cluster. or context here
#   kubeconf_opts: []

import_config "#{config_env()}.exs"
