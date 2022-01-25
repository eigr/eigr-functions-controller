import Config

config :k8s,
  clusters: %{
    default: %{
      conn: "~/.kube/config",
      conf_opts: [context: "kind-default"]
    }
  }
