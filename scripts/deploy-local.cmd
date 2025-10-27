@echo off
echo ============================================
echo Deploy Local Version (No GitHub/ArgoCD)
echo ============================================
echo.

echo Step 1: Building local image...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build failed!
    exit /b 1
)

docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build failed!
    exit /b 1
)
echo.

echo Step 2: Checking MySQL...
kubectl get pods -l app=mysql
kubectl wait --for=condition=ready pod -l app=mysql --timeout=60s
if %ERRORLEVEL% NEQ 0 (
    echo MySQL not ready! Deploying MySQL...
    kubectl apply -f k8s/mysql-pvc.yaml
    kubectl apply -f k8s/mysql-deployment.yaml
    kubectl apply -f k8s/mysql-service.yaml
    timeout /t 30 /nobreak
)
echo.

echo Step 3: Ensuring secrets exist...
kubectl get secret mysql-credentials >nul 2>&1 || (
    echo Creating MySQL secret...
    kubectl create secret generic mysql-credentials ^
      --from-literal=mysql-root-password=rootpassword ^
      --from-literal=mysql-user=springuser ^
      --from-literal=mysql-password=springpass
)
echo.

echo Step 4: Deleting old deployment...
kubectl delete deployment sso-app --ignore-not-found=true
kubectl delete pods -l app=sso-app --force --grace-period=0 >nul 2>&1
timeout /t 5 /nobreak
echo.

echo Step 5: Deploying with local image...
kubectl apply -f k8s/app-deployment-local.yaml
kubectl apply -f k8s/app-service.yaml
echo.

echo Step 6: Waiting for deployment (max 3 minutes)...
kubectl rollout status deployment/sso-app --timeout=180s
echo.

echo Step 7: Checking status...
kubectl get deployment sso-app
kubectl get pods -l app=sso-app -o wide
kubectl get svc sso-app
echo.

echo ============================================
echo Deployment Complete!
echo ============================================
echo.
echo To view logs: kubectl logs -f deployment/sso-app
echo To access app: kubectl port-forward svc/sso-app 8080:8080
echo Then open: http://localhost:8080
echo.

pause

