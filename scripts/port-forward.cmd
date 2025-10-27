@echo off
setlocal ENABLEDELAYEDEXPANSION

:: Usage:
::   scripts\port-forward.cmd [CONTEXT]
::     CONTEXT - optional kubectl context name; auto-detect if omitted

set KCTX=%1
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
  echo Enable Kubernetes in Docker Desktop or start Minikube first.
  exit /b 1
)

set CTX_ARG=--context %RESOLVED_CTX%
echo Using kubectl context: %RESOLVED_CTX%

echo Port-forwarding sso-app service on local port 8080 ...
kubectl %CTX_ARG% port-forward svc/sso-app 8080:80
