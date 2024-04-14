# Puma on Kubernetes

The code is a Rails app created with: `rails new puma-k8s-test --api --skip-active-record` with additional `Dockerfile` and multiple k8s deployment files (different Puma worker / CPU setups).

Each Puma worker is a separate process. In theory, if the call is non-blocking, the best performance/parallelism is to be achieved when there is 1/1 correspondence of workers and CPUs, without introducing any Puma threads at all. But with IO/blocking, employing some threads should yield even better performance (another thread will have a chance to do some work while the other is blocked).

So we want to achieve the best compromise of balancing: non-blocking and blocking performance and using the minimal amount of memory / CPUs for this.

## Setup

- Install minikube: https://minikube.sigs.k8s.io/docs/start/
- Install siege: https://github.com/JoeDog/siege

## Start the cluster

```bash
minikube start --cpus 8
```

## Build Docker image
Make sure the terminal is using minikube's Docker:
```bash
eval $(minikube -p minikube docker-env)
```

Build the image:

```bash
docker build -t puma-k8s-test:v1 .

```

## Deploy to k8s
```bash
kubectl delete deployment puma-k8s-test-web
kubectl apply -f deployment-<setup>.yaml
kubectl port-forward deployment/puma-k8s-test-web 3000:3000
siege -c 100 -r 50 http://localhost:3000

```

## Results

100 concurent users, each with 50 requests.

*Note*: each worker is a separate process, so e.g. if 1 worker consumes 250 MB of RAM, 4 workers would cumulatively consume 1 GB, and 8 - 2 GB. It is desirable to reduce the number of workers, to minimize memory use.

Immediate response

| Workers  | 1 CPU, trans/sec | 2 CPUs, trans/sec |
| ---------| ----- | ------ |
| 1  | 360.49 | 355.62 |
| 2  | 390.93 | 617.28 |
| 3  | 321.96 | 825.08 |
| 4  | 300.30 | 869.57 |
| 8  | 220.65 | 786.16 |

Slightly blocking response

| Workers  | 1 CPU, trans/sec | 2 CPUs, trans/sec |
| ---------| ----- | ------ |
| 1  | 106.59 | 106.70 |
| 2  | 213.40 | 212.49 |
| 3  | 327.01 | 323.83 |
| 4  | 427.72 | 428.08 |
| 8  | 271.89 | 877.19 |

