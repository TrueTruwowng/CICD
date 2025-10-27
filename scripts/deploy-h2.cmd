@echo off
echo ============================================
echo Deploy with H2 Database (No MySQL needed!)
echo ============================================
echo.

echo [1/4] Building Maven package...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build FAILED!
    pause
    exit /b 1
)
echo.

echo [2/4] Building Docker image...
docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build FAILED!
    pause
    exit /b 1
)
echo.

echo [3/4] Deploying to Kubernetes...
kubectl apply -f k8s/simple-deployment.yaml
kubectl apply -f k8s/simple-service.yaml
echo.

echo [4/4] Waiting 20 seconds for app to start...
timeout /t 20 /nobreak
echo.

echo ============================================
echo Deployment Status:
echo ============================================
kubectl get pods -l app=my-sso -o wide
echo.

echo ============================================
echo Live Logs - Wait for "Started Main in X seconds"
echo ============================================
echo.
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo Pod: %%i
    echo.
    kubectl logs -f %%i
)

echo.
echo ============================================
echo App started successfully!
echo ============================================
echo.
echo In another terminal, run:
echo   scripts\access-app-alt-port.cmd
echo.
echo Or use port 8081:
echo   kubectl port-forward svc/my-sso 8081:8080
echo   Then open: http://localhost:8081
echo.
pause

