# Exposes the two services on localhost so Postman / browser can reach them.
# With the docker driver on Windows, NodePorts are not reachable directly from the host,
# so we use kubectl port-forward. Close the two windows that open to stop forwarding.
#
#   Inventory: http://localhost:8001/docs
#   Booking:   http://localhost:8002/docs

Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl port-forward -n railbook svc/inventory-service 8001:80"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "kubectl port-forward -n railbook svc/booking-service 8002:80"

Start-Sleep -Seconds 4
Write-Host "Inventory health:" (Invoke-RestMethod http://localhost:8001/health | ConvertTo-Json -Compress)
Write-Host "Booking health:  " (Invoke-RestMethod http://localhost:8002/health | ConvertTo-Json -Compress)
Write-Host "`nSwagger UI: http://localhost:8001/docs  and  http://localhost:8002/docs" -ForegroundColor Green
