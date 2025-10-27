# CI/CD Setup Guide

## Architecture Overview

```
GitHub Repo → GitHub Actions (CI) → GHCR (Container Registry)
                                      ↓
                                ArgoCD (CD) → Kubernetes Cluster
```

## Prerequisites

1. **Docker Desktop** with Kubernetes enabled
2. **GitHub Account** with repository access
3. **GitHub Personal Access Token** (PAT) with `read:packages` and `write:packages` scope

## Quick Start

### 1. Complete Reset (if needed)
```cmd
scripts\complete-reset.cmd
```

### 2. Setup CI/CD
```cmd
scripts\setup-cicd.cmd
```

This script will:
- ✅ Install ArgoCD
- ✅ Deploy MySQL
- ✅ Create necessary secrets
- ✅ Configure ArgoCD application
- ✅ Provide ArgoCD admin password

### 3. Configure GitHub Repository

#### A. Add Repository Secrets (for CI)
Go to: `Settings → Secrets and variables → Actions → New repository secret`

No additional secrets needed! GitHub Actions uses `GITHUB_TOKEN` automatically.

#### B. Enable GitHub Packages
- Ensure your repository is public OR configure package visibility
- GitHub Actions will automatically push to `ghcr.io/YOUR_USERNAME/sso-k8s`

### 4. Push Code to GitHub
```cmd
git add .
git commit -m "Setup CI/CD with GitHub Actions and ArgoCD"
git push origin main
```

### 5. Access ArgoCD UI

```cmd
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open: https://localhost:8080

Login:
- Username: `admin`
- Password: (provided by setup script)

## CI Pipeline (GitHub Actions)

### Trigger Events
- Push to `main`, `master`, or `develop` branch
- Pull request to `main` or `master`

### Pipeline Steps
1. **Checkout code**
2. **Setup JDK 21**
3. **Build with Maven** (`./mvnw clean package -DskipTests`)
4. **Login to GHCR**
5. **Build Docker image**
6. **Push to GHCR** with tags:
   - `latest` (for default branch)
   - `branch-name` (for feature branches)
   - `sha-<commit-hash>`

### View Pipeline
- Go to: `Actions` tab in GitHub repository
- Click on latest workflow run

## CD Pipeline (ArgoCD)

### Auto-Sync Configuration
ArgoCD is configured to:
- ✅ **Automated sync**: Automatically deploy changes from Git
- ✅ **Self-heal**: Automatically fix manual changes
- ✅ **Prune**: Remove resources deleted from Git

### Sync Policy
```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
  retry:
    limit: 5
    backoff:
      duration: 5s
```

### Monitor Deployment

#### Via ArgoCD UI
1. Open ArgoCD UI (https://localhost:8080)
2. Click on `sso-k8s` application
3. View real-time sync status

#### Via kubectl
```cmd
# Check application status
kubectl get applications -n argocd

# Check pods
kubectl get pods -o wide

# Check deployment
kubectl get deployment sso-app

# View logs
kubectl logs -f deployment/sso-app
```

## Workflow

### 1. Development Workflow
```
Developer → Git Push → GitHub Actions → Build & Push Image → GHCR
                                                               ↓
                                          ArgoCD detects change
                                                               ↓
                                          Auto-sync to K8s Cluster
```

### 2. Rollback
If something goes wrong:

#### Via ArgoCD UI:
- Go to application
- Click "History and Rollback"
- Select previous version
- Click "Rollback"

#### Via kubectl:
```cmd
kubectl rollout undo deployment/sso-app
```

## Troubleshooting

### ArgoCD Pods Not Starting
```cmd
# Check pods status
kubectl get pods -n argocd

# Check pod logs
kubectl logs -n argocd <pod-name>

# Restart ArgoCD
kubectl rollout restart deployment -n argocd
```

### Application Not Syncing
```cmd
# Force sync
kubectl patch application sso-k8s -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'

# Or via ArgoCD CLI
argocd app sync sso-k8s
```

### Image Pull Errors
```cmd
# Verify GHCR secret
kubectl get secret ghcr-auth -o yaml

# Recreate secret with correct token
kubectl delete secret ghcr-auth
kubectl create secret docker-registry ghcr-auth \
  --docker-server=ghcr.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PAT \
  --docker-email=YOUR_EMAIL
```

### Pods Crashing
```cmd
# Check logs
kubectl logs -f deployment/sso-app

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name>
```

### MySQL Connection Issues
```cmd
# Check MySQL pod
kubectl get pods -l app=mysql

# Check MySQL logs
kubectl logs -l app=mysql

# Verify MySQL service
kubectl get svc mysql

# Test connection from app pod
kubectl exec -it <sso-app-pod> -- nc -zv mysql 3306
```

## Commands Reference

### ArgoCD
```cmd
# Port forward to UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# List applications
kubectl get applications -n argocd

# Sync application
argocd app sync sso-k8s
```

### Application
```cmd
# Check deployment status
kubectl get deployment sso-app

# Check pods
kubectl get pods -l app=sso-app -o wide

# View logs
kubectl logs -f deployment/sso-app

# Port forward to app
kubectl port-forward svc/sso-app 8080:8080
```

### Debugging
```cmd
# Get all resources
kubectl get all

# Describe deployment
kubectl describe deployment sso-app

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods
```

## Monitoring with Prometheus (Optional)

The application exposes Prometheus metrics at `/actuator/prometheus`.

To setup monitoring:
1. Install Prometheus on K8s
2. Configure ServiceMonitor for sso-app
3. Access metrics via Prometheus UI

## Best Practices

1. **Always use feature branches** for development
2. **Create PR** before merging to main
3. **Monitor ArgoCD UI** after deployment
4. **Check application logs** if issues occur
5. **Use semantic versioning** for releases
6. **Keep secrets secure** - never commit to Git
7. **Regular backups** of MySQL data

## Security Notes

- ArgoCD admin password is auto-generated - store securely
- Change default passwords in production
- Use RBAC for ArgoCD access control
- Rotate GitHub PAT regularly
- Use sealed secrets for sensitive data in production

## Next Steps

1. ✅ Setup CI/CD pipeline
2. ✅ Deploy application
3. 🔄 Setup monitoring with Prometheus/Grafana
4. 🔄 Configure ingress for external access
5. 🔄 Setup backup for MySQL
6. 🔄 Configure SSL/TLS
7. 🔄 Implement blue-green deployment

---

**Created by**: GitHub Copilot  
**Last Updated**: October 2025

