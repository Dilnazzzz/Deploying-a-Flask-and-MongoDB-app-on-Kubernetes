# Flask + MongoDB on Kubernetes

A compact, production‑minded example of a Flask REST API backed by MongoDB. The service is containerized with Docker and deployed to Kubernetes with health probes, resource limits, and an optional Horizontal Pod Autoscaler (HPA).

## Features
- RESTful CRUD endpoints for messages
- MongoDB with persistent storage (PVC)
- Kubernetes Deployment + Service with liveness/readiness probes
- HPA (CPU‑based) example for autoscaling
- Makefile tasks, pytest tests, and pre‑commit hooks

## Tech Stack
- Python (Flask, Flask‑PyMongo)
- Docker
- Kubernetes (Deployment, Service, PVC, HPA)

## Project Layout
- `app.py` — Flask API
- `Dockerfile` — Container build (app)
- `tasksapp.yaml`, `tasksapp-svc.yaml` — App Deployment and Service
- `mongo.yaml`, `mongo-svc.yaml`, `mongo-pv.yaml`, `mongo-pvc.yaml` — MongoDB + storage
- `hpa.yaml` — HPA targeting the app Deployment
- `Makefile` — Common tasks (`build`, `deploy`, `test`, `clean`)
- `tests/` — Pytest suite

## Quick Start (Minikube)
1) Start a local cluster and use its Docker daemon:

   ```bash
   minikube start
   eval "$(minikube docker-env)"
   ```

2) Build the image and deploy:

   ```bash
   docker build -t dilnazbaltabayeva/tasksapp-python:1.0.0 .
   kubectl apply -f tasksapp.yaml
   kubectl apply -f tasksapp-svc.yaml
   kubectl apply -f mongo-pv.yaml
   kubectl apply -f mongo-pvc.yaml
   kubectl apply -f mongo.yaml
   kubectl apply -f mongo-svc.yaml
   ```

3) Get a URL and call the API:

   - `minikube service tasksapp-svc --url`
   - Or: `kubectl port-forward deploy/tasksapp 8080:5000`

   Examples (assuming `http://127.0.0.1:8080`):

   ```bash
   curl http://127.0.0.1:8080/healthz
   curl http://127.0.0.1:8080/
   curl http://127.0.0.1:8080/messages
   curl -X POST -H "Content-Type: application/json" \
     -d '{"message":"Hello"}' http://127.0.0.1:8080/message
   ```

## API
- `GET /` — Greeting with pod hostname
- `GET /healthz` — Healthcheck (used by probes)
- `GET /messages` — List messages
- `POST /message` — Create message; body: `{ "message": "..." }`
- `PUT /message/<id>` — Update by id; body: `{ "message": "..." }`
- `DELETE /message/<id>` — Delete by id
- `POST /messages/delete` — Delete all messages

Responses are JSON with appropriate HTTP status codes.

## Configuration
- `MONGO_URI` — Mongo connection string. Defaults to `mongodb://mongo:27017/dev`.
- To override, add an env var to the Deployment container:

  ```yaml
  env:
    - name: MONGO_URI
      value: mongodb://mongo:27017/dev
  ```

For production, prefer `Secret`/`ConfigMap` and authenticated MongoDB.

## Autoscaling (HPA)
Enable the metrics server in Minikube, then apply the HPA:

```bash
minikube addons enable metrics-server
kubectl apply -f hpa.yaml
kubectl get hpa
```

Under sustained CPU load, the HPA scales the `tasksapp` Deployment between 1–5 replicas.

## Storage
The provided `PersistentVolume` uses `hostPath` for Minikube. On managed clusters, use a `StorageClass` (dynamic provisioning) and remove the static PV.

## Local Development
```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
pytest -q
pre-commit install && pre-commit run -a
```

## Makefile Targets
- `make build` — Build the Docker image
- `make deploy` — Apply app + Mongo manifests
- `make hpa` — Apply the HPA
- `make test` — Run pytest
- `make precommit` — Run code quality hooks
- `make clean` — Delete applied Kubernetes resources

## Teardown
```bash
kubectl delete -f tasksapp.yaml -f tasksapp-svc.yaml \
  -f mongo.yaml -f mongo-svc.yaml -f mongo-pvc.yaml -f mongo-pv.yaml \
  -f hpa.yaml
```
