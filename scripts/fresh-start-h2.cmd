@echo off
echo ============================================
echo Complete Cleanup and Fresh H2 Deployment
echo ============================================
echo.

echo [1/6] Removing all old deployments...
kubectl delete deployment my-sso mysql sso-app sso-app-v2 --ignore-not-found=true
kubectl delete service my-sso mysql sso-app sso-app-v2 --ignore-not-found=true
kubectl delete pods -l app=my-sso --force --grace-period=0 >nul 2>&1
kubectl delete pods -l app=mysql --force --grace-period=0 >nul 2>&1
kubectl delete pods -l app=sso-app --force --grace-period=0 >nul 2>&1
kubectl delete pods -l app=sso-app-v2 --force --grace-period=0 >nul 2>&1
echo Old resources deleted
timeout /t 5 /nobreak >nul
echo.

echo [2/6] Building Maven package with H2...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build FAILED!
    pause
    exit /b 1
)
echo.

echo [3/6] Building Docker image...
docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build FAILED!
    pause
    exit /b 1
)
echo.

echo [4/6] Deploying fresh instance with H2...
kubectl apply -f k8s/simple-deployment.yaml
kubectl apply -f k8s/simple-service.yaml
echo.

echo [5/6] Waiting 25 seconds for app to fully start...
timeout /t 25 /nobreak
echo.

echo [6/6] Current status:
kubectl get pods -o wide
echo.
kubectl get services
echo.

echo ============================================
echo Checking application logs...
echo ============================================
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo.
    echo Pod: %%i
    echo Last 50 log lines:
    echo ============================================
    kubectl logs %%i --tail=50
    echo ============================================
)

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo To access the application:
echo   kubectl port-forward svc/my-sso 8081:8080
echo   Open: http://localhost:8081
echo.
echo Or run: scripts\access-app-alt-port.cmd
echo.
pause

