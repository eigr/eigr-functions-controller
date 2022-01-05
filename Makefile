.PHONY: clean compile build install example local

BONNY_IMAGE=eigr/permastate:0.1.29

all: clean compile build
#all: clean compile build install

compile:
	mix deps.get
	mix compile

build:
	docker build -t ${BONNY_IMAGE} .
	docker push ${BONNY_IMAGE}:latest

local:
	- rm manifest.yaml
	mix bonny.gen.manifest
	kubectl apply -f ./manifest.yaml
	iex -S mix

install:
	mix compile
	mix bonny.gen.manifest --image ${BONNY_IMAGE}
	kubectl apply -f ./manifest.yaml
	kubectl get all

example:
	kubectl apply -f ./example.yaml
	kubectl get all

clean:
	- kubectl delete -f ./example.yaml
	sleep 5
	- kubectl delete -f ./manifest.yaml
	- rm manifest.yaml
	- rm -rf mix.lock _build deps
