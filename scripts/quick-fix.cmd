@echo off
echo ============================================
echo Quick Fix for Stuck Deployment
echo ============================================
echo.

echo This will:
echo 1. Remove imagePullPolicy restriction (use local images)
echo 2. Disable health checks temporarily
echo 3. Restart deployment
echo.
set /p CONFIRM="Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" exit /b 0

echo.
echo Step 1: Checking if local image exists...
docker images | findstr sso-k8s

echo.
echo Step 2: Tagging local image for K8s...
docker tag sso-k8s:local ghcr.io/truetruwowng/sso-k8s:latest

echo.
echo Step 3: Creating temporary deployment (no health checks)...
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sso-app
  labels:
    app: sso-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sso-app
  template:
    metadata:
      labels:
        app: sso-app
    spec:
      containers:
        - name: sso-app
          image: ghcr.io/truetruwowng/sso-k8s:latest
          imagePullPolicy: IfNotPresent
          env:
            - name: SPRING_DATASOURCE_URL
              value: jdbc:mysql://mysql:3306/spring_security_demo?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
            - name: SPRING_DATASOURCE_USERNAME
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: mysql-user
            - name: SPRING_DATASOURCE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-credentials
                  key: mysql-password
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
EOF

echo.
echo Step 4: Waiting for pod to start...
timeout /t 10 /nobreak
kubectl get pods -l app=sso-app

echo.
echo Step 5: Checking logs...
for /f "tokens=1" %%i in ('kubectl get pods -l app=sso-app -o jsonpath^="{.items[0].metadata.name}"') do (
    kubectl logs %%i --tail=30
)

echo.
echo ============================================
echo Quick fix applied!
echo ============================================
echo.
echo Check if pod is running: kubectl get pods
echo View logs: kubectl logs -f deployment/sso-app
echo.
pause

