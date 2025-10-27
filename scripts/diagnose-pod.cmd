@echo off
echo ============================================
echo Diagnose Pod Issues
echo ============================================
echo.

echo [1] Getting pod name...
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do set POD_NAME=%%i

if "%POD_NAME%"=="" (
    echo ERROR: No pod found with label app=my-sso
    echo.
    echo Checking all pods:
    kubectl get pods -o wide
    pause
    exit /b 1
)

echo Pod: %POD_NAME%
echo.

echo [2] Pod Status:
kubectl get pod %POD_NAME% -o wide
echo.

echo [3] Pod Events:
kubectl describe pod %POD_NAME% | findstr /C:"Events:" /A 20
echo.

echo [4] Container Logs (last 100 lines):
echo ============================================
kubectl logs %POD_NAME% --tail=100
echo ============================================
echo.

echo [5] Checking if port 8080 is open in container:
kubectl exec %POD_NAME% -- netstat -tlnp 2>nul || kubectl exec %POD_NAME% -- ss -tlnp 2>nul || echo "netstat/ss not available"
echo.

echo [6] Checking Java process:
kubectl exec %POD_NAME% -- ps aux 2>nul || echo "ps not available"
echo.

echo [7] Container environment:
kubectl exec %POD_NAME% -- env | findstr SPRING
echo.

echo ============================================
echo Diagnosis complete. Check logs above.
echo ============================================
pause

