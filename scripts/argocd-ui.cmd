@echo off
echo ============================================
echo ArgoCD Quick Access
echo ============================================
echo.

echo Starting ArgoCD UI port forward...
echo.
echo ArgoCD will be available at: https://localhost:8080
echo Username: admin
echo.

echo Getting admin password...
for /f "delims=" %%i in ('kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath^="{.data.password}"') do set ARGOCD_PASSWORD_B64=%%i
powershell -Command "[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%ARGOCD_PASSWORD_B64%'))" > argocd-temp-pwd.txt
set /p ARGOCD_PASSWORD=<argocd-temp-pwd.txt
del argocd-temp-pwd.txt

echo Password: %ARGOCD_PASSWORD%
echo.
echo Opening port forward (keep this window open)...
echo Press Ctrl+C to stop
echo.

kubectl port-forward svc/argocd-server -n argocd 8080:443
