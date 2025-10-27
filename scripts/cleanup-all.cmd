@echo off
echo ============================================
echo Cleanup All SSO Deployments
echo ============================================
echo.
echo This will delete:
echo   - sso-app (old stuck deployment)
echo   - sso-app-v2 (new deployment)
echo   - All related pods and services
echo.
set /p CONFIRM="Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" exit /b 0
echo.

echo Deleting sso-app (old)...
kubectl delete deployment sso-app --ignore-not-found=true --timeout=5s
kubectl delete service sso-app --ignore-not-found=true
kubectl delete pods -l app=sso-app --force --grace-period=0

echo.
echo Deleting sso-app-v2...
kubectl delete deployment sso-app-v2 --ignore-not-found=true --timeout=5s
kubectl delete service sso-app-v2 --ignore-not-found=true
kubectl delete pods -l app=sso-app-v2 --force --grace-period=0

echo.
echo Waiting for cleanup to complete...
timeout /t 5 /nobreak

echo.
echo Checking remaining resources...
kubectl get deployments
echo.
kubectl get pods -o wide
echo.
kubectl get services

echo.
echo ============================================
echo Cleanup complete!
echo ============================================
echo.
echo To deploy fresh: scripts\deploy-v2.cmd
echo.
pause

