@echo off
echo ============================================
echo Check What's Using Port 8080
echo ============================================
echo.

echo Checking port 8080...
netstat -ano | findstr :8080

echo.
echo If you see LISTENING above, port 8080 is in use.
echo Run scripts\kill-port-8080.cmd to free it.
echo.
pause

