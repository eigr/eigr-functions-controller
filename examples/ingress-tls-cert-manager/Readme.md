# TLS Ingress with CertManager Deployment

The Eigr Functions controller is capable of generating the necessary annotations so that the ingress can be exposed through a certificate managed by [CertManager](https://cert-manager.io/) but there are some limitations that must be considered for this to work correctly.

1. CertManager must be installed on your Kubernetes cluster.
2. There must be a previously configured [ClusterIssuer](https://cert-manager.io/docs/concepts/issuer/).
