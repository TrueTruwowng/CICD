@echo off
echo ============================================
echo Setup CI/CD with GitHub Actions and ArgoCD
echo ============================================
echo.

echo Prerequisites:
echo 1. GitHub repository: https://github.com/truetruwowng/CICD
echo 2. Docker Desktop Kubernetes running
echo 3. GitHub Personal Access Token (PAT) with packages permission
echo.
set /p CONTINUE="Continue? (Y/N): "
if /i not "%CONTINUE%"=="Y" exit /b 0
echo.

REM ===== Step 1: Install ArgoCD =====
echo [1/8] Installing ArgoCD...
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo Waiting for ArgoCD to be ready...
timeout /t 30 /nobreak >nul
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
echo ArgoCD installed successfully!
echo.

REM ===== Step 2: Get ArgoCD Password =====
echo [2/8] Retrieving ArgoCD admin password...
timeout /t 5 /nobreak >nul
for /f "delims=" %%i in ('kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath^="{.data.password}"') do set ARGOCD_PASSWORD_B64=%%i
powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%ARGOCD_PASSWORD_B64%'))" > argocd-password.txt
set /p ARGOCD_PASSWORD=<argocd-password.txt
del argocd-password.txt
echo ArgoCD Password: %ARGOCD_PASSWORD%
echo.

REM ===== Step 3: Create GHCR Secret =====
echo [3/8] Creating GitHub Container Registry secret...
echo.
set /p GITHUB_USERNAME="Enter your GitHub username (default: truetruwowng): "
if "%GITHUB_USERNAME%"=="" set GITHUB_USERNAME=truetruwowng

set /p GITHUB_TOKEN="Enter your GitHub PAT (with read:packages and write:packages): "
if "%GITHUB_TOKEN%"=="" (
    echo ERROR: GitHub token is required!
    pause
    exit /b 1
)

kubectl create secret docker-registry ghcr-auth ^
  --docker-server=ghcr.io ^
  --docker-username=%GITHUB_USERNAME% ^
  --docker-password=%GITHUB_TOKEN% ^
  --docker-email=%GITHUB_USERNAME%@users.noreply.github.com ^
  --dry-run=client -o yaml | kubectl apply -f -
echo GHCR secret created!
echo.

REM ===== Step 4: Update deployment to use GHCR =====
echo [4/8] Updating deployment manifest to use GHCR image...
powershell -Command "(Get-Content k8s\simple-deployment.yaml) -replace 'image: sso-k8s:local', 'image: ghcr.io/%GITHUB_USERNAME%/sso-k8s:latest' | Set-Content k8s\simple-deployment.yaml"
powershell -Command "(Get-Content k8s\simple-deployment.yaml) -replace 'imagePullPolicy: IfNotPresent', 'imagePullPolicy: Always' | Set-Content k8s\simple-deployment.yaml"
echo.

REM ===== Step 5: Add imagePullSecrets to deployment =====
echo [5/8] Adding imagePullSecrets to deployment...
powershell -Command "$content = Get-Content k8s\simple-deployment.yaml -Raw; if ($content -notmatch 'imagePullSecrets') { $content = $content -replace '(spec:[\r\n]+      containers:)', \"spec:`r`n      imagePullSecrets:`r`n        - name: ghcr-auth`r`n      containers:\" }; $content | Set-Content k8s\simple-deployment.yaml"
echo.

REM ===== Step 6: Build and push initial image =====
echo [6/8] Building and pushing initial Docker image...
call mvnw.cmd clean package -DskipTests
if %ERRORLEVEL% NEQ 0 (
    echo Maven build failed!
    pause
    exit /b 1
)

docker build -t ghcr.io/%GITHUB_USERNAME%/sso-k8s:latest .
echo Logging in to GHCR...
echo %GITHUB_TOKEN% | docker login ghcr.io -u %GITHUB_USERNAME% --password-stdin
docker push ghcr.io/%GITHUB_USERNAME%/sso-k8s:latest
echo Initial image pushed to GHCR!
echo.

REM ===== Step 7: Deploy ArgoCD Application =====
echo [7/8] Deploying ArgoCD Application...
kubectl apply -f k8s/argocd-app.yaml
timeout /t 5 /nobreak >nul
echo ArgoCD Application deployed!
echo.

REM ===== Step 8: Check status =====
echo [8/8] Checking deployment status...
kubectl get applications -n argocd
echo.
kubectl get pods -o wide
echo.
kubectl get services
echo.

echo ============================================
echo CI/CD Setup Complete!
echo ============================================
echo.
echo ArgoCD Admin Credentials:
echo   Username: admin
echo   Password: %ARGOCD_PASSWORD%
echo.
echo To access ArgoCD UI:
echo   kubectl port-forward svc/argocd-server -n argocd 8080:443
echo   Open: https://localhost:8080
echo.
echo Next Steps:
echo   1. Commit and push your changes to GitHub:
echo      git add .
echo      git commit -m "Setup CI/CD with GitHub Actions and ArgoCD"
echo      git push origin main
echo.
echo   2. GitHub Actions will automatically build and push the image
echo   3. ArgoCD will automatically sync and deploy to Kubernetes
echo.
echo To monitor:
echo   - GitHub Actions: https://github.com/%GITHUB_USERNAME%/CICD/actions
echo   - ArgoCD: https://localhost:8080 (after port-forward)
echo   - Application: kubectl port-forward svc/my-sso 8081:8080
echo.
pause

