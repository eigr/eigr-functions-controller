# Eigr Functions

The eigr serverless compute project

## Install

```shell
kubectl apply -f https://github.com/eigr/eigr-functions-controller/blob/main/manifests/manifest.yaml
```

## Usage

Apply Function CRD to create k8s resources

```shell
cat <<EOF | kubectl apply --filename -
apiVersion: functions.eigr.io/v1
kind: Function
metadata:
  name: shopping-cart 
  namespace: my-functions
spec:
  backend:
    image: cloudstateio/cloudstate-python-tck:latest
EOF
```

For more usage examples see examples folder