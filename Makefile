.PHONY: clean compile build install example local

BONNY_IMAGE=ghcr.io/eigr/functions-controller:0.1.37

all: clean compile build
#all: clean compile build install

compile:
	mix deps.get
	mix compile

build:
	docker build -t ${BONNY_IMAGE} .
	docker push ${BONNY_IMAGE}
	MIX_ENV=dev mix bonny.gen.manifest --out eigr-functions.yaml -n eigr-functions --image ${BONNY_IMAGE}

local:
	- rm manifest.yaml
	kubectl create namespace eigr-functions	
	MIX_ENV=dev mix bonny.gen.manifest --out dev.yaml -n eigr-functions
	kubectl apply -f ./dev.yaml
	MIX_ENV=dev iex -S mix

install:
	MIX_ENV=prod mix compile
	MIX_ENV=prod mix bonny.gen.manifest --out eigr-functions.yaml -n eigr-functions --image ${BONNY_IMAGE}
	kubectl create namespace eigr-functions	
	kubectl apply -f ./eigr-functions.yaml
	kubectl get all

example:
	kubectl apply -f ./function-example.yaml
	kubectl get all

clean:
	- kubectl delete namespace eigr-functions
	- kubectl delete -f ./function-example.yaml
	sleep 5
	- kubectl delete -f ./eigr-functions.yaml
	- rm eigr-functions.yaml
	- rm -rf mix.lock _build deps
