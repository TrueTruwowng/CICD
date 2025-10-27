@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Complete Status Check
echo ============================================
echo.

echo [Deployments]
kubectl get deployments -o wide
echo.

echo [Pods]
kubectl get pods -o wide
echo.

echo [Services]
kubectl get services -o wide
echo.

echo [my-sso Pod Details]
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo.
    echo === Pod: %%i ===
    kubectl get pod %%i -o wide
    echo.
    echo Recent Events:
    kubectl describe pod %%i | findstr /C:"Events:" /A 10
    echo.
    echo Last 20 log lines:
    kubectl logs %%i --tail=20
)

echo.
echo ============================================
echo Quick Commands:
echo   View logs: scripts\logs.cmd
echo   Access app: scripts\access-app.cmd
echo   Rebuild: scripts\rebuild-no-delete.cmd
echo ============================================
pause
@echo off
echo ============================================
echo Rebuild and Redeploy (NO POD DELETION)
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

echo [3/4] Applying updated deployment (rolling update)...
kubectl apply -f k8s/simple-deployment.yaml
kubectl apply -f k8s/simple-service.yaml
echo.

echo [4/4] Waiting for rolling update to complete...
echo.
kubectl get pods -l app=my-sso -o wide -w

