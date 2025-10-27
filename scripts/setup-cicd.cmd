@echo off
REM ==============================================================================
REM Complete CI/CD Setup Script for Docker Desktop Kubernetes + ArgoCD
REM ==============================================================================

echo ============================================
echo Complete CI/CD Setup
echo ============================================
echo.

REM Step 1: Ensure kubectl is configured
echo Step 1: Checking Kubernetes connection...
kubectl cluster-info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Cannot connect to Kubernetes cluster!
    echo Please ensure Docker Desktop Kubernetes is running.
    exit /b 1
)
echo ✓ Kubernetes cluster is accessible
echo.

REM Step 2: Create namespace for ArgoCD if not exists
echo Step 2: Creating ArgoCD namespace...
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
echo.

REM Step 3: Install ArgoCD
echo Step 3: Installing ArgoCD...
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo ✓ ArgoCD installation initiated
echo.

REM Step 4: Wait for ArgoCD to be ready
echo Step 4: Waiting for ArgoCD pods to be ready (this may take 2-3 minutes)...
timeout /t 30 /nobreak >nul
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
echo ✓ ArgoCD is ready
echo.

REM Step 5: Create MySQL secret
echo Step 5: Creating MySQL credentials secret...
kubectl create secret generic mysql-credentials ^
  --from-literal=mysql-root-password=rootpassword ^
  --from-literal=mysql-user=springuser ^
  --from-literal=mysql-password=springpass ^
  --dry-run=client -o yaml | kubectl apply -f -
echo ✓ MySQL credentials created
echo.

REM Step 6: Deploy MySQL
echo Step 6: Deploying MySQL...
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml
echo ✓ MySQL deployment initiated
echo.

REM Step 7: Wait for MySQL to be ready
echo Step 7: Waiting for MySQL to be ready...
timeout /t 20 /nobreak >nul
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s
echo ✓ MySQL is ready
echo.

REM Step 8: Create GHCR secret for pulling images
echo Step 8: Creating GitHub Container Registry secret...
echo NOTE: You need to provide your GitHub Personal Access Token (PAT)
echo.
set /p GITHUB_USERNAME="Enter your GitHub username (default: truetruwowng): "
if "%GITHUB_USERNAME%"=="" set GITHUB_USERNAME=truetruwowng

set /p GITHUB_TOKEN="Enter your GitHub PAT (with read:packages scope): "
if "%GITHUB_TOKEN%"=="" (
    echo WARNING: No token provided. Using placeholder.
    echo You must update this secret later with: kubectl create secret docker-registry ghcr-auth ...
    set GITHUB_TOKEN=placeholder
)

kubectl create secret docker-registry ghcr-auth ^
  --docker-server=ghcr.io ^
  --docker-username=%GITHUB_USERNAME% ^
  --docker-password=%GITHUB_TOKEN% ^
  --docker-email=%GITHUB_USERNAME%@users.noreply.github.com ^
  --dry-run=client -o yaml | kubectl apply -f -
echo ✓ GHCR secret created
echo.

REM Step 9: Apply ArgoCD Application
echo Step 9: Creating ArgoCD Application...
kubectl apply -f k8s/argocd-app.yaml
echo ✓ ArgoCD Application created
echo.

REM Step 10: Get ArgoCD admin password
echo Step 10: Retrieving ArgoCD admin password...
timeout /t 5 /nobreak >nul
for /f "delims=" %%i in ('kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath^="{.data.password}"') do set ARGOCD_PASSWORD_B64=%%i
powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%ARGOCD_PASSWORD_B64%'))" > argocd-password.txt
set /p ARGOCD_PASSWORD=<argocd-password.txt
del argocd-password.txt
echo.

echo ============================================
echo Setup Complete!
echo ============================================
echo.
echo ArgoCD Admin Credentials:
echo   Username: admin
echo   Password: %ARGOCD_PASSWORD%
echo.
echo To access ArgoCD UI:
echo   1. Run: kubectl port-forward svc/argocd-server -n argocd 8080:443
echo   2. Open: https://localhost:8080
echo   3. Login with credentials above
echo.
echo To check application status:
echo   kubectl get applications -n argocd
echo   kubectl get pods -o wide
echo.
echo Next steps:
echo   1. Push your code to GitHub
echo   2. GitHub Actions will build and push the Docker image
echo   3. ArgoCD will automatically sync and deploy the application
echo.
echo ============================================

pause

