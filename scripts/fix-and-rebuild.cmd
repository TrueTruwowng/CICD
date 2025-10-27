@echo off
echo ============================================
echo Fix and Rebuild Everything
echo ============================================
echo.

echo [1/6] Rebuilding Maven package with updated config...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build FAILED!
    pause
    exit /b 1
)
echo.

echo [2/6] Rebuilding Docker image...
docker build -t sso-k8s:local .
if %ERRORLEVEL% NEQ 0 (
    echo Docker build FAILED!
    pause
    exit /b 1
)
echo.

echo [3/6] Ensuring MySQL is running and configured...
kubectl get pods -l app=mysql -o wide
for /f "tokens=1" %%p in ('kubectl get pods -l app^=mysql -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo.
    echo Configuring MySQL database in pod %%p...
    kubectl exec %%p -- mysql -uroot -prootpassword -e "CREATE DATABASE IF NOT EXISTS spring_security_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
    kubectl exec %%p -- mysql -uroot -prootpassword -e "CREATE USER IF NOT EXISTS 'springuser'@'%%' IDENTIFIED BY 'springpass';" 2>nul
    kubectl exec %%p -- mysql -uroot -prootpassword -e "GRANT ALL PRIVILEGES ON spring_security_demo.* TO 'springuser'@'%%';" 2>nul
    kubectl exec %%p -- mysql -uroot -prootpassword -e "FLUSH PRIVILEGES;" 2>nul
    echo MySQL configuration completed!
)
echo.

echo [4/6] Applying updated deployment (rolling update)...
kubectl apply -f k8s/simple-deployment.yaml
kubectl apply -f k8s/simple-service.yaml
echo.

echo [5/6] Waiting 30 seconds for new pod to start...
timeout /t 30 /nobreak
echo.

echo [6/6] Pod Status:
kubectl get pods -l app=my-sso -o wide
echo.

echo ============================================
echo Live Logs - Watch for "Started Main in X seconds"
echo ============================================
echo.
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo Pod: %%i
    echo.
    kubectl logs -f %%i
)

