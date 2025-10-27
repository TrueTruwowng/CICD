@echo off
echo ============================================
echo View Live Logs
echo ============================================
echo.

for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo Following logs for pod: %%i
    echo Press Ctrl+C to stop
    echo.
    timeout /t 2 /nobreak >nul
    kubectl logs -f %%i
)

if "%ERRORLEVEL%" NEQ "0" (
    echo No pod found with label app=my-sso
    echo.
    kubectl get pods -o wide
)

pause

