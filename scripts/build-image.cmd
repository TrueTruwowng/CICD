@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Usage: scripts\build-image.cmd [IMAGE_NAME]
:: Example: scripts\build-image.cmd sso-k8s:local

set IMAGE=%1
if "%IMAGE%"=="" set IMAGE=sso-k8s:local

echo Building JAR...
call mvnw.cmd -DskipTests package || goto :error

echo Building Docker image %IMAGE% ...
docker build -t %IMAGE% . || goto :error

echo Image built: %IMAGE%
exit /b 0

:error
echo Build failed with error %ERRORLEVEL%.
exit /b %ERRORLEVEL%

