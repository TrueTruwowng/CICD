@echo off
echo Getting logs from my-sso pod...
echo.
for /f "tokens=1" %%i in ('kubectl get pods -l app^=my-sso -o jsonpath^="{.items[0].metadata.name}" 2^>nul') do (
    echo Pod: %%i
    echo.
    kubectl logs %%i --tail=200
)
pause

