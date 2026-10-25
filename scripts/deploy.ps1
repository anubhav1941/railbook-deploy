# RailBook: one-shot deployment to a local minikube cluster (Windows PowerShell).
# Run from the railbook-deploy folder:   .\scripts\deploy.ps1
# Expects inventory-service and booking-service cloned next to railbook-deploy.

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$parent = Split-Path -Parent $root

Write-Host "`n[1/6] Starting minikube (docker driver, 3 GB RAM, 2 CPU)..." -ForegroundColor Cyan
$status = minikube status --format "{{.Host}}" 2>$null
if ($status -ne "Running") {
    minikube start --driver=docker --memory=3072 --cpus=2
}

Write-Host "`n[2/6] Enabling addons: metrics-server (for HPA) and dashboard..." -ForegroundColor Cyan
minikube addons enable metrics-server
minikube addons enable dashboard

Write-Host "`n[3/6] Building service images inside minikube..." -ForegroundColor Cyan
minikube image build -t railbook/inventory-service:1.0 "$parent\inventory-service"
minikube image build -t railbook/booking-service:1.0 "$parent\booking-service"
minikube image ls | Select-String "railbook"

Write-Host "`n[4/6] Creating namespace and databases..." -ForegroundColor Cyan
kubectl apply -f "$root\k8s\00-namespace.yaml"
kubectl apply -f "$root\k8s\10-inventory-db.yaml"
kubectl apply -f "$root\k8s\20-booking-db.yaml"
kubectl rollout status statefulset/inventory-db -n railbook --timeout=180s
kubectl rollout status statefulset/booking-db -n railbook --timeout=180s

Write-Host "`n[5/6] Deploying microservices..." -ForegroundColor Cyan
kubectl apply -f "$root\k8s\30-inventory-service.yaml"
kubectl apply -f "$root\k8s\40-booking-service.yaml"
kubectl rollout status deployment/inventory-service -n railbook --timeout=180s
kubectl rollout status deployment/booking-service -n railbook --timeout=180s

Write-Host "`n[6/6] Done. Current state:" -ForegroundColor Green
kubectl get all -n railbook
kubectl get pvc -n railbook

Write-Host "`nNext:" -ForegroundColor Yellow
Write-Host "  .\scripts\port-forward.ps1      -> APIs on http://localhost:8001 and http://localhost:8002"
Write-Host "  minikube dashboard              -> Kubernetes dashboard in the browser"
