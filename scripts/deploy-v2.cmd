@echo off
echo ============================================
echo Deploy SSO App V2 (Fresh Deployment)
echo ============================================
echo.

echo Step 1: Cleaning up old stuck deployment...
kubectl delete deployment sso-app --ignore-not-found=true --timeout=10s
kubectl delete pods -l app=sso-app --force --grace-period=0 >nul 2>&1
kubectl delete service sso-app --ignore-not-found=true
echo Old deployment cleanup initiated
echo.

echo Step 2: Building fresh Docker image...
echo Building Maven package...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build failed!
    exit /b 1
)

echo Building Docker image...
docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build failed!
    exit /b 1
)
echo Docker image built successfully
echo.

echo Step 3: Verifying MySQL is running...
kubectl get pods -l app=mysql -o wide
kubectl wait --for=condition=ready pod -l app=mysql --timeout=30s 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo MySQL not ready! Deploying MySQL...
    kubectl apply -f k8s/mysql-pvc.yaml
    kubectl apply -f k8s/mysql-deployment.yaml
    kubectl apply -f k8s/mysql-service.yaml
    echo Waiting for MySQL to start...
    timeout /t 30 /nobreak
    kubectl wait --for=condition=ready pod -l app=mysql --timeout=60s
)
echo MySQL is ready
echo.

echo Step 4: Ensuring MySQL credentials secret exists...
kubectl get secret mysql-credentials >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Creating MySQL credentials...
    kubectl create secret generic mysql-credentials ^
      --from-literal=mysql-root-password=rootpassword ^
      --from-literal=mysql-user=springuser ^
      --from-literal=mysql-password=springpass
    echo Secret created
) else (
    echo Secret already exists
)
echo.

echo Step 5: Deploying SSO App V2...
kubectl apply -f k8s/app-deployment-v2.yaml
kubectl apply -f k8s/app-service-v2.yaml
echo Deployment manifests applied
echo.

echo Step 6: Waiting for pods to be ready (timeout 3 minutes)...
echo This may take a while as the application starts up...
kubectl rollout status deployment/sso-app-v2 --timeout=180s
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Deployment is taking longer than expected...
    echo Checking pod status:
    kubectl get pods -l app=sso-app-v2 -o wide
    echo.
    echo Checking pod events:
    for /f "tokens=1" %%i in ('kubectl get pods -l app^=sso-app-v2 -o name 2^>nul') do (
        echo.
        echo Events for %%i:
        kubectl describe %%i | findstr /C:"Events:" /A 15
        echo.
        echo Logs for %%i:
        kubectl logs %%i --tail=30 2>nul
    )
    echo.
    echo Deployment may need more time. Check logs with:
    echo   kubectl logs -f deployment/sso-app-v2
    pause
    exit /b 1
)
echo.

echo Step 7: Deployment Status
echo ============================================
kubectl get deployment sso-app-v2
echo.
kubectl get pods -l app=sso-app-v2 -o wide
echo.
kubectl get svc sso-app-v2
echo.

echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo Application: sso-app-v2
echo Service: sso-app-v2
echo.
echo To view logs:
echo   kubectl logs -f deployment/sso-app-v2
echo.
echo To access the application:
echo   kubectl port-forward svc/sso-app-v2 8080:8080
echo   Then open: http://localhost:8080
echo.
echo To check pod details:
echo   kubectl describe pod -l app=sso-app-v2
echo.

pause

