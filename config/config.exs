use Mix.Config

config :logger, level: :debug

if Mix.env() == :dev do
  config :k8s,
    clusters: %{
      default: %{
        conf: "~/.kube/config",
        conf_opts: [context: "kind-default"]
      }
    }

  config :bonny,
    cluster_name: :default
end

if Mix.env() == :prod do
  config :k8s,
         clusters: %{
           default: %{}
         }

  config :bonny,
         cluster_name: :default
end

config :bonny,
  # Add each CRD Controller module for this operator to load here
  controllers: [
    # PermastateOperator.Controller.V1alpha1.StatefulStore,
    PermastateOperator.Controller.V1alpha1.StatefulServices
  ],
  cluster_name: :default,
  namespace: :all,

  #   # Set the Kubernetes API group for this operator.
  #   # This can be overwritten using the @group attribute of a controller
  #   group: "your-operator.example.com",

  #   # Name must only consist of only lowercase letters and hyphens.
  #   # Defaults to hyphenated mix app name
  operator_name: "permastate-operator",

  #   # Name must only consist of only lowercase letters and hyphens.
  #   # Defaults to hyphenated mix app name
  #   service_account_name: "your-operator",

  #   # Labels to apply to the operator's resources.
  labels: %{
    cloudsate_protocol_minor_version: "1",
    cloudsate_protocol_major_version: "0",
    proxy_name: "massa-proxy"
  }

#   # Operator deployment resources. These are the defaults.
#   resources: %{
#     limits: %{cpu: "200m", memory: "200Mi"},
#     requests: %{cpu: "200m", memory: "200Mi"}
#   },

#   # Defaults to "current-context" if a config file is provided, override user, cluster. or context here
#   kubeconf_opts: []
