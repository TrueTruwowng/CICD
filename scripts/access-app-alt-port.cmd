@echo off
echo ============================================
echo Access App on Different Port
echo ============================================
echo.

set /p PORT="Enter port number to use (default 8081): "
if "%PORT%"=="" set PORT=8081

echo.
echo Forwarding http://localhost:%PORT% to my-sso service...
echo Keep this window open!
echo.
echo Access your app at: http://localhost:%PORT%
echo.
echo Press Ctrl+C to stop port forwarding
echo.

kubectl port-forward svc/my-sso %PORT%:8080

