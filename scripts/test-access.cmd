@echo off
echo ============================================
echo Test App Access
echo ============================================
echo.

echo Checking pod status...
kubectl get pods -l app=my-sso -o wide
echo.

for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo Testing pod: %%i
    echo.

    echo [Test 1] Checking if port 8080 is listening...
    kubectl exec %%i -- sh -c "netstat -tln 2>/dev/null | grep :8080 || ss -tln 2>/dev/null | grep :8080 || echo 'Port check tools not available'"
    echo.

    echo [Test 2] Checking Java process...
    kubectl exec %%i -- ps aux 2>nul | findstr java
    echo.

    echo [Test 3] Testing HTTP from inside pod...
    kubectl exec %%i -- sh -c "wget -q -O- http://localhost:8080/actuator/health 2>&1 || curl -s http://localhost:8080/actuator/health 2>&1 || echo 'HTTP test tools not available'"
    echo.

    echo [Test 4] Last 30 lines of logs...
    kubectl logs %%i --tail=30
)

echo.
echo ============================================
echo If port 8080 is listening and logs show
echo "Started Main in X seconds", try:
echo   kubectl port-forward svc/my-sso 8080:8080
echo ============================================
pause

