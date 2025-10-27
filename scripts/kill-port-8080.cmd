@echo off
echo ============================================
echo Kill Process Using Port 8080
echo ============================================
echo.

echo Finding process using port 8080...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do (
    set PID=%%a
    echo Found process PID: %%a
    echo Killing process...
    taskkill /F /PID %%a
)

echo.
echo Port 8080 is now free!
echo.
pause

