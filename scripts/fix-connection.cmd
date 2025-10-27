@echo off
echo ============================================
echo Fix Connection Refused Issue
echo ============================================
echo.

echo Step 1: Checking current pod logs...
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo Current pod logs:
    kubectl logs %%i --tail=50
)
echo.

echo Step 2: Deleting current deployment...
kubectl delete deployment my-sso --force --grace-period=0
kubectl delete pods -l app=my-sso --force --grace-period=0
timeout /t 5 /nobreak >nul
echo.

echo Step 3: Rebuilding application...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build failed!
    pause
    exit /b 1
)
echo.

echo Step 4: Rebuilding Docker image...
docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build failed!
    pause
    exit /b 1
)
echo.

echo Step 5: Verifying MySQL is accessible...
kubectl get pods -l app=mysql -o wide
for /f "tokens=1" %%p in ('kubectl get pods -l app^=mysql -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo Testing MySQL connection in pod %%p...
    kubectl exec %%p -- mysql -uroot -prootpassword -e "CREATE DATABASE IF NOT EXISTS spring_security_demo; GRANT ALL ON spring_security_demo.* TO 'springuser'@'%%' IDENTIFIED BY 'springpass'; FLUSH PRIVILEGES;" 2>nul
    if !ERRORLEVEL! EQU 0 (
        echo MySQL database configured successfully
    ) else (
        echo MySQL command completed
    )
)
echo.

echo Step 6: Redeploying with updated config...
kubectl apply -f k8s/simple-deployment.yaml
kubectl apply -f k8s/simple-service.yaml
echo.

echo Step 7: Waiting for pod to start...
timeout /t 15 /nobreak
echo.

echo Step 8: Checking new pod status...
kubectl get pods -l app=my-sso -o wide
echo.

echo Step 9: Showing live logs (Ctrl+C to stop)...
echo Press Ctrl+C when you see "Started Main in" message
echo.
timeout /t 3 /nobreak >nul
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    kubectl logs -f %%i
)

pause
