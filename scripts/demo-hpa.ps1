# Autoscaling demo: generates load on inventory-service and watches the HPA scale it out.
# Press Ctrl+C to stop watching, then the load generator is removed.
$root = Split-Path -Parent $PSScriptRoot
kubectl apply -f "$root\k8s\90-load-generator.yaml"
Write-Host "Load started. Watching HPA (takes 1-2 minutes to react)..." -ForegroundColor Cyan
try {
    kubectl get hpa -n railbook -w
}
finally {
    kubectl delete -f "$root\k8s\90-load-generator.yaml"
    Write-Host "Load generator removed. HPA scales back down after ~5 minutes." -ForegroundColor Yellow
}
