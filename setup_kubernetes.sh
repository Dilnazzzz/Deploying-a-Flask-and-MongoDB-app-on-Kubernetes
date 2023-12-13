
# Set Docker environment to Minikube's Docker daemon
echo "Setting Docker environment to Minikube's Docker daemon..."
eval $(minikube docker-env)

# Build the Docker image
echo "Building Docker image..."

docker build -t dilnazbaltabayeva/tasksapp-python:1.0.0 .
docker push dilnazbaltabayeva/tasksapp-python:1.0.0

# Apply the Kubernetes configurations
echo "Applying Kubernetes deployments and services..."
kubectl apply -f tasksapp.yaml
kubectl apply -f tasksapp-svc.yaml

# Create autoscaler
kubectl apply -f hpa.yaml
kubectl autoscale deployment hpa-scale --cpu-percent=50 --min=1 --max=10

# Create the MongoDB deployment and service
kubectl create -f mongo-pv.yaml
kubectl create -f mongo-pvc.yaml
kubectl create -f mongo.yaml
kubectl create -f mongo-svc.yaml

echo "Setup complete!"