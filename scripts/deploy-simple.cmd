@echo off
echo ============================================
echo Simple Deployment - No Health Checks
echo ============================================
echo.

echo [1/7] Force cleaning ALL old deployments...
kubectl delete deployment sso-app --force --grace-period=0 >nul 2>&1
kubectl delete deployment sso-app-v2 --force --grace-period=0 >nul 2>&1
kubectl delete deployment my-sso --force --grace-period=0 >nul 2>&1
kubectl delete service sso-app --force --grace-period=0 >nul 2>&1
kubectl delete service sso-app-v2 --force --grace-period=0 >nul 2>&1
kubectl delete service my-sso --force --grace-period=0 >nul 2>&1
kubectl delete pods -l app=sso-app --force --grace-period=0 >nul 2>&1
kubectl delete pods -l app=sso-app-v2 --force --grace-period=0 >nul 2>&1
kubectl delete pods -l app=my-sso --force --grace-period=0 >nul 2>&1
echo Old resources deleted
timeout /t 3 /nobreak >nul
echo.

echo [2/7] Building Maven package...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build FAILED!
    pause
    exit /b 1
)
echo.

echo [3/7] Building Docker image...
docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build FAILED!
    pause
    exit /b 1
)
echo.

echo [4/7] Checking MySQL...
kubectl get pods -l app=mysql | findstr Running >nul
if %ERRORLEVEL% NEQ 0 (
    echo MySQL not running, deploying...
    kubectl apply -f k8s/mysql-pvc.yaml
    kubectl apply -f k8s/mysql-deployment.yaml
    kubectl apply -f k8s/mysql-service.yaml
    echo Waiting 30s for MySQL...
    timeout /t 30 /nobreak
)
echo MySQL OK
echo.

echo [5/7] Creating MySQL secret...
kubectl delete secret mysql-credentials --ignore-not-found=true >nul 2>&1
kubectl create secret generic mysql-credentials ^
  --from-literal=mysql-root-password=rootpassword ^
  --from-literal=mysql-user=springuser ^
  --from-literal=mysql-password=springpass
echo.

echo [6/7] Deploying my-sso (simple, no health checks)...
kubectl apply -f k8s/simple-deployment.yaml
kubectl apply -f k8s/simple-service.yaml
echo.

echo [7/7] Waiting for pod to start (max 60s)...
timeout /t 10 /nobreak >nul

kubectl get pods -l app=my-sso
echo.

echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo Service Name: my-sso
echo NodePort: 30080
echo.
echo Check status:
echo   kubectl get pods -l app=my-sso -o wide
echo.
echo View logs:
echo   kubectl logs -f -l app=my-sso
echo.
echo Access app:
echo   Method 1: http://localhost:30080 (if NodePort works)
echo   Method 2: kubectl port-forward svc/my-sso 8080:8080
echo            then http://localhost:8080
echo.

pause

