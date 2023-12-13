#!/bin/bash

# Delete the Kubernetes deployment and service
echo "Deleting Kubernetes deployment and service..."
kubectl delete deployment tasksapp
kubectl delete service tasksapp-svc

echo "Teardown complete!"