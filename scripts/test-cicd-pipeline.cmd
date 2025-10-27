@echo off
echo ============================================
echo Test Complete CI/CD Pipeline
echo ============================================
echo.

echo This will make a small change and trigger the full CI/CD pipeline.
echo.
set /p CONTINUE="Continue? (Y/N): "
if /i not "%CONTINUE%"=="Y" exit /b 0
echo.

echo [1/5] Making a test change to trigger CI...
echo # Test change - %date% %time% >> README.md
git add README.md
git commit -m "Test CI/CD pipeline - %date% %time%"
echo.

echo [2/5] Pushing to GitHub (this will trigger GitHub Actions)...
git push
if %ERRORLEVEL% NEQ 0 (
    echo Git push failed! Check your git configuration.
    pause
    exit /b 1
)
echo.

echo [3/5] GitHub Actions is now running...
echo Check progress at: https://github.com/truetruwowng/CICD/actions
echo.
echo Waiting 60 seconds for build to complete...
timeout /t 60 /nobreak
echo.

echo [4/5] Checking ArgoCD sync status...
kubectl get application sso-app -n argocd
echo.

echo [5/5] Checking pod status...
kubectl get pods -l app=my-sso -o wide
echo.

echo ============================================
echo CI/CD Pipeline Test
echo ============================================
echo.
echo Next Steps:
echo   1. Check GitHub Actions: https://github.com/truetruwowng/CICD/actions
echo   2. Check ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443
echo   3. Monitor pods: kubectl get pods -w
echo.
echo If everything works, you should see:
echo   - GitHub Actions build completes successfully
echo   - ArgoCD detects the change
echo   - New pods are deployed automatically
echo.
pause

