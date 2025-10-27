@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Usage:
::   scripts\reset-k8s.cmd [MODE] [CONTEXT] [NAMESPACE]
::     MODE     - desktop | minikube | cloud   (default: desktop)
::     CONTEXT  - kubectl context name         (auto-detect if omitted)
::     NAMESPACE- namespace to operate in      (default: default)
::
:: Optional: set K8S_VALIDATE=false to add --validate=false to kubectl apply
::
set MODE=%1
if "%MODE%"=="" set MODE=desktop
set KCTX=%2
set NS=%3
if "%NS%"=="" set NS=default

set VALIDATE_ARG=
if /I "%%K8S_VALIDATE%%"=="false" set VALIDATE_ARG=--validate=false

:: Resolve context (auto-detect docker-desktop or minikube)
set RESOLVED_CTX=
if not "%KCTX%"=="" (
  for /f "usebackq tokens=*" %%c in (`kubectl --context %KCTX% config current-context 2^>nul`) do set RESOLVED_CTX=%%c
  if not "%RESOLVED_CTX%"=="" set RESOLVED_CTX=%KCTX%
)
if "%RESOLVED_CTX%"=="" (
  for /f "usebackq tokens=*" %%c in (`kubectl config current-context 2^>nul`) do set RESOLVED_CTX=%%c
)
if "%RESOLVED_CTX%"=="" (
  for /f "usebackq tokens=*" %%c in (`kubectl config get-contexts -o name 2^>nul ^| findstr /i "docker-desktop"`) do set RESOLVED_CTX=%%c
)
if "%RESOLVED_CTX%"=="" (
  for /f "usebackq tokens=*" %%c in (`kubectl config get-contexts -o name 2^>nul ^| findstr /i "minikube"`) do set RESOLVED_CTX=%%c
)
if "%RESOLVED_CTX%"=="" (
  echo ERROR: No kubectl context detected.
  echo Enable Kubernetes in Docker Desktop or start Minikube ^(minikube start --driver=docker^) and retry.
  exit /b 1
)
set CTX_ARG=--context %RESOLVED_CTX%

:: Ensure namespace exists
kubectl %CTX_ARG% get ns %NS% >nul 2>&1 || kubectl %CTX_ARG% create ns %NS%

echo ===== Cleaning old resources in namespace '%NS%' on context '%RESOLVED_CTX%' =====
:: Kill port-forward if any (best effort)
for /f "usebackq tokens=5" %%p in (`netstat -ano ^| findstr ":8080"`) do taskkill /PID %%p /F >nul 2>&1

:: Delete legacy demo resources
kubectl %CTX_ARG% -n %NS% delete svc my-app-svc --ignore-not-found=true
kubectl %CTX_ARG% -n %NS% delete deploy my-app --ignore-not-found=true

:: Delete our app resources if exist
kubectl %CTX_ARG% -n %NS% delete svc sso-app --ignore-not-found=true
kubectl %CTX_ARG% -n %NS% delete deploy sso-app --ignore-not-found=true

:: Delete MySQL stack and PVC if exist
kubectl %CTX_ARG% -n %NS% delete deploy mysql --ignore-not-found=true
kubectl %CTX_ARG% -n %NS% delete svc mysql --ignore-not-found=true
kubectl %CTX_ARG% -n %NS% delete pvc mysql-pvc --ignore-not-found=true
kubectl %CTX_ARG% -n %NS% delete secret mysql-credentials --ignore-not-found=true

:: Small wait for GC
ping -n 3 127.0.0.1 >nul

:: Re-deploy clean with our script and local image
call "%~dp0build-image.cmd" sso-k8s:local || goto :error
call "%~dp0deploy-k8s.cmd" sso-k8s:local %MODE% %RESOLVED_CTX% || goto :error

:: Show status and helpful next steps
kubectl %CTX_ARG% -n %NS% get pods -o wide
kubectl %CTX_ARG% -n %NS% get svc sso-app -o wide

echo If no external IP is present, port-forward with:
echo   scripts\port-forward.cmd %RESOLVED_CTX%
exit /b 0

:error
echo Reset failed with error %ERRORLEVEL%.
exit /b %ERRORLEVEL%

