@echo off
echo ============================================
echo Troubleshooting Deployment Issues
echo ============================================
echo.

echo Step 1: Checking pod status...
kubectl get pods -o wide
echo.

echo Step 2: Checking deployment status...
kubectl describe deployment sso-app
echo.

echo Step 3: Getting pod events (last 3 pods)...
for /f "tokens=1" %%i in ('kubectl get pods -l app=sso-app -o name') do (
    echo.
    echo === Events for %%i ===
    kubectl describe %%i | findstr /C:"Events:" /A 30
)
echo.

echo Step 4: Checking pod logs (if any pod is running)...
for /f "tokens=1" %%i in ('kubectl get pods -l app=sso-app -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo.
    echo === Logs for %%i ===
    kubectl logs %%i --tail=50 2>nul || echo No logs available yet
)
echo.

echo Step 5: Checking MySQL connectivity...
kubectl get pods -l app=mysql
kubectl get svc mysql
echo.

echo Step 6: Checking secrets...
kubectl get secret ghcr-auth -o jsonpath="{.data.\.dockerconfigjson}" >nul 2>&1 && (
    echo [OK] GHCR secret exists
) || (
    echo [ERROR] GHCR secret not found!
)

kubectl get secret mysql-credentials -o jsonpath="{.data.mysql-user}" >nul 2>&1 && (
    echo [OK] MySQL secret exists
) || (
    echo [ERROR] MySQL secret not found!
)
echo.

pause

