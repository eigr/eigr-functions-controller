# Developer Guide

Here are some basic tips for compiling and generating Kuberne artifactors.

## Prerequisites

Obviously you will need a kubernete environment. The easiest way to start is by creating a cluster with kind (you will need the docker)

```
kind create cluster --name default
```

## Compilation

```
mix deps.get && mix compile
```

## Generate artifacts and deploy on k8s

```
mix bonny.gen.dockerfile
docker build -t ${BONNY_IMAGE} . 
docker push ${BONNY_IMAGE}:latest

mix bonny.gen.manifest --image ${BONNY_IMAGE}
kubectl apply -f ./manifest.yaml
kubectl get all
```

Or simply:

```
make build && make apply
```

To test the operator you can use the StatefulService CRD found in the example file.

```
kubectl apply -f example.yaml
```