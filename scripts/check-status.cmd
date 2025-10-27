@echo off
echo ============================================
echo Quick Check - What's Running?
echo ============================================
echo.

echo === All Deployments ===
kubectl get deployments
echo.

echo === All Pods ===
kubectl get pods -o wide
echo.

echo === All Services ===
kubectl get services
echo.

echo === Events (last 20) ===
kubectl get events --sort-by='.lastTimestamp' | findstr /V "Normal" | more +0
echo.

echo ============================================
echo Commands:
echo   View logs: kubectl logs -f POD_NAME
echo   Delete stuck: kubectl delete pod POD_NAME --force --grace-period=0
echo   Deploy simple: scripts\deploy-simple.cmd
echo ============================================
echo.
pause

