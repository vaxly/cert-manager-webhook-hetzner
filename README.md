# ACME Webhook for Hetzner DNS

This project provides a [cert-manager](https://cert-manager.io) ACME Webhook for [Hetzner DNS](https://hetzner.de/) 
and is based on the [Example Webhook](https://github.com/jetstack/cert-manager-webhook-example)

This README and the inspiration for this webhook was mostly taken from [Stephan Müllers INWX Webhook](https://gitlab.com/smueller18/cert-manager-webhook-inwx).

The Helm Chart is automatically published via [github pages](https://mecodia.github.io/cert-manager-webhook-hetzner/).
## Tutorial

https://thedatabaseme.de/2021/12/28/kubernetes-cert-manager-mit-hetzner-dns-nutzen/

## Requirements

-   [helm](https://helm.sh/) >= v3.0.0
-   [kubernetes](https://kubernetes.io/) >= v1.14.0
-   [cert-manager](https://cert-manager.io/) >= 0.12.0

## Configuration

The following table lists the configurable parameters of the cert-manager chart and their default values.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `groupName` | Group name of the API service. | `dns.hetzner.cloud` |
| `certManager.namespace` | Namespace where cert-manager is deployed to. | `kube-system` |
| `certManager.serviceAccountName` | Service account of cert-manager installation. | `cert-manager` |
| `image.repository` | Image repository | `mecodia/cert-manager-webhook-hetzner` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `service.type` | API service type | `ClusterIP` |
| `service.port` | API service port | `443` |
| `resources` | CPU/memory resource requests/limits | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `affinity` | Node affinity for pod assignment | `{}` |
| `tolerations` | Node tolerations for pod assignment | `[]` |

## Installation

### cert-manager

Follow the [instructions](https://cert-manager.io/docs/installation/) using the cert-manager documentation to install it within your cluster.

### Webhook

```bash
git clone https://github.com/mecodia/cert-manager-webhook-hetzner.git
cd cert-manager-webhook-hetzner
helm install --namespace kube-system cert-manager-webhook-hetzner ./deploy/cert-manager-webhook-hetzner
```

**Note**: The kubernetes resources used to install the Webhook should be deployed within the same namespace as the cert-manager.

To uninstall the webhook run
```bash
helm uninstall --namespace kube-system cert-manager-webhook-hetzner
```

## Issuer

Create a `ClusterIssuer` or `Issuer` resource as following:
```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory

    # Email address used for ACME registration
    email: mail@example.com # REPLACE THIS WITH YOUR EMAIL!!!

    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging

    solvers:
      - dns01:
          webhook:
            groupName: dns.hetzner.cloud
            solverName: hetzner
            config:
              APIKey: <YOUR-DNS-API-KEY-HERE>
```

### Credentials

For accessing the Hetzner DNS API, you need an API Token which you can create in the [DNS Console](https://dns.hetzner.com/settings/api-token).

Currently we don't provide a way to use secrets for you API KEY.

### Create a certificate

Finally you can create certificates, for example:

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: example-cert
  namespace: cert-manager
spec:
  commonName: example.com
  dnsNames:
    - example.com
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-staging
  secretName: example-cert
```

## Development

### Requirements

-   [go](https://golang.org/) >= 1.13.0

### Running the test suite

1. Download test binaries
    ```bash
    scripts/fetch-test-binaries.sh
    ```

1. Create a new test account at [Hetzner DNS Console](https://dns.hetzner.com/) or use an existing account

1. Go to `testdata/config.json` and replace your api key.

1. Download dependencies
    ```bash
    go mod download
    ```

An example Go test file has been provided in [main_test.go](https://github.com/jetstack/cert-manager-webhook-example/blob/master/main_test.go).

### Running the full suite with microk8s

Tested with Ubuntu:

```bash
sudo snap install microk8s --classic
sudo microk8s.enable dns rbac
sudo microk8s.kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
sudo microk8s.config > /tmp/microk8s.config
export KUBECONFIG=/tmp/microk8s.config
helm install --namespace kube-system cert-manager-webhook-hetzner deploy/hetzner-webhook
```
