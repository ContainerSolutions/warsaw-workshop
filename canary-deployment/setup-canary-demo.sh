#!/bin/bash

if [[ -z $1 ]]
then
  echo "Please provide your username"
  exit 1
fi
  

if [[ ! -d "${HOME}/canary-deployment-demo" ]]
then
  mkdir -p ${HOME}/canary-deployment-demo/app/{v1,v2,v3}
else
  echo "remove directory ${HOME}/canary-deployment-demo in order to recreate k8s recources"
  exit 1
fi

dst="${HOME}/canary-deployment-demo/app/"

echo "Generating k8s resources"

#Create gateway
echo "apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: hello-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - \"*\"
    port:
      number: 80
      name: http
      protocol: HTTP" > $dst/../gateway.yaml

#Create V1

echo "kind: ReplicaSet
apiVersion: apps/v1
metadata:
  name: hello-world-v1
  labels:
    app: hello-world
    version: v1
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-world
      version: v1
  template:
    metadata:
        labels:
          app: hello-world
          version: v1
    spec:
      containers:
        - name: hello
          image: ottovsky/deployment-strategy-demo:v1
          imagePullPolicy: Always
          ports:
            - containerPort: 80" > $dst/v1/replicaset-v1.yaml

echo "kind: Service
apiVersion: v1
metadata:
  name: hello-world
  labels:
    app: hello-world
spec:
  selector:
    app: hello-world
  ports:
    - port: 80
      name: http" > $dst/v1/service.yaml

echo "apiVersion: v1
kind: List
items:
- kind: VirtualService
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-vs
  spec:
    hosts:
    - \"*\"
    gateways:
    - hello-gateway
    http:
      - match:
        - uri:
            prefix: "/$1"
        route:
        - destination:
            host: hello-world
            subset: v1
- kind: DestinationRule
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-world
  spec:
    host: hello-world
    subsets:
    - name: v1
      labels:
        version: v1" > $dst/v1/istio.yaml

#Create V2

echo "kind: ReplicaSet
apiVersion: apps/v1
metadata:
  name: hello-world-v2
  labels:
    app: hello-world
    version: v2
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-world
      version: v2
  template:
    metadata:
        labels:
          app: hello-world
          version: v2
    spec:
      containers:
        - name: hello
          image: ottovsky/deployment-strategy-demo:v2
          imagePullPolicy: Always
          ports:
            - containerPort: 80" > $dst/v2/replicaset-v2.yaml

echo "apiVersion: v1
kind: List
items:
- kind: VirtualService
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-vs
  spec:
    hosts:
    - \"*\"
    gateways:
    - hello-gateway
    http:
      - match:
        - uri:
            prefix: "/$1"
        route:
        - destination:
            host: hello-world
            subset: v1
          weight: 95
        - destination:
            host: hello-world
            subset: v2
          weight: 5
- kind: DestinationRule
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-world
  spec:
    host: hello-world
    subsets:
    - name: v1
      labels:
        version: v1
    - name: v2
      labels:
        version: v2" > $dst/v2/istio-try-5-percent.yaml


#Create V3
echo "kind: ReplicaSet
apiVersion: apps/v1
metadata:
  name: hello-world-v3
  labels:
    app: hello-world
    version: v3
spec:
  replicas: 10
  selector:
    matchLabels:
      app: hello-world
      version: v3
  template:
    metadata:
        labels:
          app: hello-world
          version: v3
    spec:
      containers:
        - name: hello
          image: ottovsky/deployment-strategy-demo:v3
          imagePullPolicy: Always
          ports:
            - containerPort: 80" > $dst/v3/replicaset-v3.yaml

echo "apiVersion: v1
kind: List
items:
- kind: VirtualService
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-vs
  spec:
    hosts:
    - \"*\"
    gateways:
    - hello-gateway
    http:
      - match:
        - uri:
            prefix: "/$1"
        route:
        - destination:
            host: hello-world
            subset: v1
          weight: 95
        - destination:
            host: hello-world
            subset: v3
          weight: 5
- kind: DestinationRule
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-world
  spec:
    host: hello-world
    subsets:
    - name: v1
      labels:
        version: v1
    - name: v3
      labels:
        version: v3" > $dst/v3/istio-try-5-percent.yaml

echo "kind: VirtualService
apiVersion: networking.istio.io/v1alpha3
metadata:
  name: hello-vs
spec:
  hosts:
  - \"*\"
  gateways:
  - hello-gateway
  http:
    - match:
      - uri:
          prefix: "/$1"
      route:
      - destination:
          host: hello-world
          subset: v1
        weight: 50
      - destination:
          host: hello-world
          subset: v3
        weight: 50" > $dst/v3/istio-try-50-percent.yaml

echo "apiVersion: v1
kind: List
items:
- kind: VirtualService
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-vs
  spec:
    hosts:
    - \"*\"
    gateways:
    - hello-gateway
    http:
      - match:
        - uri:
            prefix: "/$1"
        route:
        - destination:
            host: hello-world
            subset: v3
          weight: 100
- kind: DestinationRule
  apiVersion: networking.istio.io/v1alpha3
  metadata:
    name: hello-world
  spec:
    host: hello-world
    subsets:
    - name: v3
      labels:
        version: v3" > $dst/v3/istio-100-percent.yaml

echo "Installing python in the container"         

apt-get install -y python python-requests

echo "During this hands on, connect to the prometheus instance provided by
presenters and invoke the following query to track request repartition between
different versions of application: "
echo ""
echo "sum(rate(istio_requests_total{destination_service=\"hello-world.$1.svc.cluster.local\"}[1m])) by (response_code, destination_version)"
echo ""
echo "Success"
