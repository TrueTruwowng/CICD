@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Quick Deploy - Just Deploy It!
echo ============================================
echo.

echo [1/3] Applying deployment (no deletion, just update)...
kubectl apply -f k8s/simple-deployment.yaml
kubectl apply -f k8s/simple-service.yaml
echo.

echo [2/3] Waiting 25 seconds for container to start...
echo (If pod already exists, it will do rolling update)
timeout /t 25 /nobreak
echo.

echo [3/3] Pod Status:
kubectl get pods -l app=my-sso -o wide
echo.

echo ============================================
echo Live logs (wait for "Started Main in" message):
echo ============================================
timeout /t 2 /nobreak >nul
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    set POD_NAME=%%i
    echo Pod: !POD_NAME!
    echo.
    kubectl logs -f !POD_NAME!
)

echo.
echo ============================================
echo After you see "Started Main in X seconds"
echo Open ANOTHER terminal and run:
echo   kubectl port-forward svc/my-sso 8080:8080
echo Then access: http://localhost:8080
echo ============================================
pause
