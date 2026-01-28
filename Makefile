IMAGE ?= tasksapp-python:dev

.PHONY: build deploy deploy-app deploy-mongo hpa test clean precommit fmt

build:
	@echo "Building Docker image $(IMAGE)"
	docker build -t $(IMAGE) .

deploy-app:
	@echo "Applying app manifests"
	kubectl apply -f tasksapp.yaml
	kubectl apply -f tasksapp-svc.yaml

deploy-mongo:
	@echo "Applying MongoDB manifests"
	kubectl apply -f mongo-pv.yaml
	kubectl apply -f mongo-pvc.yaml
	kubectl apply -f mongo.yaml
	kubectl apply -f mongo-svc.yaml

deploy: deploy-app deploy-mongo

hpa:
	@echo "Applying HPA"
	kubectl apply -f hpa.yaml

test:
	pytest -q

clean:
	@echo "Deleting resources"
	kubectl delete -f tasksapp.yaml --ignore-not-found
	kubectl delete -f tasksapp-svc.yaml --ignore-not-found
	kubectl delete -f mongo.yaml --ignore-not-found
	kubectl delete -f mongo-svc.yaml --ignore-not-found
	kubectl delete -f mongo-pvc.yaml --ignore-not-found
	kubectl delete -f mongo-pv.yaml --ignore-not-found
	kubectl delete -f hpa.yaml --ignore-not-found

precommit:
	pre-commit install
	pre-commit run -a

