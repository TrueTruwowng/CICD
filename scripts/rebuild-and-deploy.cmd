@echo off
echo ============================================
echo Rebuilding and Redeploying Application
echo ============================================

echo.
echo Step 1: Building Maven package...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build failed!
    exit /b 1
)

echo.
echo Step 2: Building Docker image...
docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build failed!
    exit /b 1
)

echo.
echo Step 3: Deleting old deployment...
kubectl delete deployment sso-app --ignore-not-found=true
kubectl delete pods -l app=sso-app --grace-period=0 --force

echo.
echo Step 4: Applying new deployment...
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml

echo.
echo Step 5: Waiting for deployment...
kubectl rollout status deployment/sso-app --timeout=300s

echo.
echo Step 6: Checking status...
kubectl get deployment sso-app
kubectl get pods -l app=sso-app -o wide

echo.
echo ============================================
echo Deployment Complete!
echo ============================================
echo To check logs: kubectl logs -f deployment/sso-app
echo To port-forward: kubectl port-forward svc/sso-app 8080:8080

