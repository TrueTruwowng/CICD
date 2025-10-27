@echo off
REM ==============================================================================
REM Complete Reset - Remove all K8s resources and ArgoCD
REM ==============================================================================

echo ============================================
echo Complete Kubernetes Reset
echo ============================================
echo.
echo WARNING: This will delete ALL resources including:
echo   - ArgoCD and all applications
echo   - sso-app deployment
echo   - MySQL database and data
echo   - All secrets and configs
echo.
set /p CONFIRM="Are you sure? Type 'YES' to continue: "
if not "%CONFIRM%"=="YES" (
    echo Reset cancelled.
    exit /b 0
)
echo.

echo Step 1: Deleting ArgoCD application...
kubectl delete application sso-k8s -n argocd --ignore-not-found=true
timeout /t 5 /nobreak >nul

echo Step 2: Deleting sso-app resources...
kubectl delete deployment sso-app --ignore-not-found=true
kubectl delete service sso-app --ignore-not-found=true
kubectl delete pods -l app=sso-app --force --grace-period=0

echo Step 3: Deleting MySQL resources...
kubectl delete deployment mysql --ignore-not-found=true
kubectl delete service mysql --ignore-not-found=true
kubectl delete pvc mysql-pvc --ignore-not-found=true
kubectl delete pods -l app=mysql --force --grace-period=0

echo Step 4: Deleting secrets...
kubectl delete secret mysql-credentials --ignore-not-found=true
kubectl delete secret ghcr-auth --ignore-not-found=true

echo Step 5: Deleting ArgoCD namespace...
kubectl delete namespace argocd --ignore-not-found=true

echo.
echo Waiting for resources to be fully deleted...
timeout /t 10 /nobreak >nul

echo.
echo ============================================
echo Reset Complete!
echo ============================================
echo.
echo All resources have been deleted.
echo To setup again, run: scripts\setup-cicd.cmd
echo.

pause

