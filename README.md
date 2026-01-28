# Flask + MongoDB on Kubernetes

Production‑ready example of a minimal Flask API backed by MongoDB, containerized with Docker, and deployed to Kubernetes. Includes manifests for the application and MongoDB with persistent storage.

This project is intended to demonstrate the end‑to‑end workflow: build a container, deploy to a cluster, expose the service, and interact with the API.

## Features
- Minimal Flask CRUD API for messages
- MongoDB deployment with PVC for persistence
- Kubernetes `Deployment` + `Service` for the app
- Easy local deployment on Minikube

## Repository Layout
- `app.py` — Flask API with MongoDB integration
- `Dockerfile` — Container image for the API
- `tasksapp.yaml`, `tasksapp-svc.yaml` — App `Deployment` and `Service`
- `mongo.yaml`, `mongo-svc.yaml`, `mongo-pv.yaml`, `mongo-pvc.yaml` — MongoDB + storage
- `hpa.yaml` — Example autoscale target resources (see notes below)
- `setup_kubernetes.sh`, `teardown_kubernetes.sh` — Convenience scripts

## Prerequisites
- Docker
- kubectl
- Minikube (for local cluster)

## Quick Start (Minikube)
1) Start Minikube and point Docker to it

   ```bash
   minikube start
   eval "$(minikube docker-env)"
   ```

2) Build the image and deploy manifests

   ```bash
   docker build -t dilnazbaltabayeva/tasksapp-python:1.0.0 .
   kubectl apply -f tasksapp.yaml
   kubectl apply -f tasksapp-svc.yaml
   kubectl apply -f mongo-pv.yaml
   kubectl apply -f mongo-pvc.yaml
   kubectl apply -f mongo.yaml
   kubectl apply -f mongo-svc.yaml
   ```

3) Get the service URL and test

   - With Minikube LoadBalancer emulation: `minikube service tasksapp-svc --url`
   - Or port‑forward: `kubectl port-forward deploy/tasksapp 8080:5000`

   Example requests (assuming `http://127.0.0.1:8080`):

   ```bash
   curl http://127.0.0.1:8080/
   curl http://127.0.0.1:8080/messages
   curl -X POST -H "Content-Type: application/json" \
     -d '{"message":"Hello"}' http://127.0.0.1:8080/message
   ```

## API Endpoints
- `GET /` — Service greeting + pod hostname
- `GET /messages` — List all messages
- `POST /message` — Create a message
  - Body: `{ "message": "..." }`
- `PUT /message/<id>` — Update a message by id
  - Body: `{ "message": "..." }`
- `DELETE /message/<id>` — Delete a message by id
- `POST /messages/delete` — Delete all messages

Responses are JSON; errors return a JSON message and HTTP status.

## Configuration
- The app connects to the in‑cluster MongoDB service named `mongo` on `27017`, using database `dev` (see `app.py`).
- For production, prefer injecting configuration via environment variables and Kubernetes `Secret`/`ConfigMap` (see “Improvements” below).

## Autoscaling (HPA)
An example resource file `hpa.yaml` is included, but it currently defines a separate demo `Deployment`/`Service`. For real autoscaling of `tasksapp`, use:

```bash
kubectl autoscale deployment tasksapp --cpu-percent=50 --min=1 --max=10
```

For production, define an `autoscaling/v2` HPA YAML targeting the `tasksapp` deployment with CPU/Memory metrics.

## Notes on Storage
The provided `PersistentVolume` uses `hostPath` for simplicity and portability on Minikube. On managed clusters, replace with an appropriate `StorageClass` and remove the static PV.

## Improvements and Next Steps
These are recommended changes to make the project more robust and portfolio‑quality:

Application
- Read `MONGO_URI` from an environment variable (fallback to `mongodb://mongo:27017/dev`).
- Add input validation and proper error handling for invalid IDs and missing fields.
- Add `/healthz` endpoint for liveness checks.
- Add unit tests with `pytest` and `mongomock`.

Container
- Switch to `python:3.11-slim`, install from `requirements.txt`, and run as non‑root.
- Use Gunicorn in production and add a Docker `HEALTHCHECK`.

Kubernetes
- Add resource requests/limits and liveness/readiness probes to `tasksapp.yaml`.
- Store MongoDB credentials in a `Secret`; connect with auth enabled.
- Replace `hpa.yaml` with a proper `HorizontalPodAutoscaler` targeting `tasksapp`.
- Add an `Ingress` (or Gateway) and make the `Service` a `ClusterIP`.
- Organize manifests under a `k8s/` directory and consider Kustomize or Helm.

DX and CI
- Add a `Makefile` (build, push, deploy, test) and `pre-commit` hooks (black/flake8/isort).
- Add GitHub Actions: run tests, lint Dockerfile (hadolint), validate YAML, build/push image on tags.

Documentation
- Include an architecture diagram and badges (tests, image, license).
- Add a `.env.example` and a local dev flow using Docker Compose.

## Teardown
```bash
kubectl delete -f tasksapp.yaml -f tasksapp-svc.yaml \
  -f mongo.yaml -f mongo-svc.yaml -f mongo-pvc.yaml -f mongo-pv.yaml
```

---

If you want, I can apply the improvements above (starting with environment‑based config, probes, and a refined HPA) and add CI + a Makefile.
