# Removes everything RailBook created in the cluster (namespace delete also removes PVCs).
kubectl delete namespace railbook --ignore-not-found
Write-Host "To stop the cluster:   minikube stop"
Write-Host "To delete the cluster: minikube delete"
