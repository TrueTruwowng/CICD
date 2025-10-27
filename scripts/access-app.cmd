@echo off
echo ============================================
echo Port Forward to my-sso Service
echo ============================================
echo.

echo Checking if port 8080 is already in use...
netstat -ano | findstr :8080 | findstr LISTENING >nul
if %ERRORLEVEL% EQU 0 (
    echo.
    echo WARNING: Port 8080 is already in use!
    echo.
    netstat -ano | findstr :8080
    echo.
    set /p KILL="Do you want to kill the process? (Y/N): "
    if /i "!KILL!"=="Y" (
        for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do (
            echo Killing process PID %%a...
            taskkill /F /PID %%a
        )
        timeout /t 2 /nobreak >nul
    ) else (
        echo Port forward cancelled.
        pause
        exit /b 1
    )
)

echo.
echo Forwarding http://localhost:8080 to my-sso service...
echo Keep this window open!
echo.
echo Access your app at: http://localhost:8080
echo.
echo Press Ctrl+C to stop port forwarding
echo.

kubectl port-forward svc/my-sso 8080:8080
