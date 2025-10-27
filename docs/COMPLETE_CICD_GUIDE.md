kubectl describe application sso-app -n argocd
```

### Check Deployment
```cmd
kubectl get pods -o wide
kubectl get deployments
kubectl logs -f deployment/my-sso
```

### ArgoCD CLI (Optional)
```cmd
# Install ArgoCD CLI
# Windows: Download from https://github.com/argoproj/argo-cd/releases

# Login
argocd login localhost:8080 --insecure

# Sync manually
argocd app sync sso-app

# Get app info
argocd app get sso-app
```

## Troubleshooting

### GitHub Actions Fails

**Image push fails:**
- Check GitHub PAT has `write:packages` permission
- Verify token in repository secrets
- Check package visibility (public/private)

**Build fails:**
- Check Java version (need 21)
- Check Maven dependencies
- Review build logs

### ArgoCD Not Syncing

**Check application status:**
```cmd
kubectl get application sso-app -n argocd -o yaml
```

**Force sync:**
```cmd
kubectl patch application sso-app -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

**Or via UI:**
- Login to ArgoCD UI
- Click on `sso-app`
- Click "Sync" button

### Pods Not Starting

**Image pull error:**
```cmd
# Check secret
kubectl get secret ghcr-auth -o yaml

# Recreate secret
kubectl delete secret ghcr-auth
kubectl create secret docker-registry ghcr-auth \
  --docker-server=ghcr.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PAT \
  --docker-email=YOUR_EMAIL
```

**Check logs:**
```cmd
kubectl logs -f deployment/my-sso
kubectl describe pod POD_NAME
```

## Rollback

### Via ArgoCD UI
1. Go to ArgoCD UI
2. Click on `sso-app`
3. Click "History and Rollback"
4. Select previous revision
5. Click "Rollback"

### Via kubectl
```cmd
kubectl rollout undo deployment/my-sso
```

### Via Git
```cmd
git revert HEAD
git push
# ArgoCD will auto-deploy the reverted version
```

## Security Best Practices

1. **Use GitHub Secrets** - Store PAT in repository secrets (not in code)
2. **Use Read-Only PAT for ArgoCD** - ArgoCD only needs read access
3. **Enable Branch Protection** - Require PR reviews before merge
4. **Scan Images** - Add security scanning to GitHub Actions
5. **RBAC in ArgoCD** - Configure role-based access control

## Advanced Configuration

### Multi-Environment Setup

Create different ArgoCD applications for each environment:

```yaml
# argocd-app-dev.yaml
spec:
  source:
    targetRevision: develop
  destination:
    namespace: dev

# argocd-app-prod.yaml
spec:
  source:
    targetRevision: main
  destination:
    namespace: prod
```

### Custom Sync Waves

Add annotations to control deployment order:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

### Health Checks

ArgoCD automatically monitors:
- Deployment rollout status
- Pod readiness
- Service endpoints

## Next Steps

1. ✅ Setup complete CI/CD pipeline
2. 🔄 Add tests to CI pipeline
3. 🔄 Setup staging environment
4. 🔄 Add Prometheus monitoring
5. 🔄 Configure Slack/Discord notifications
6. 🔄 Add automatic rollback on failure

---

**Setup Date:** October 27, 2025  
**GitHub Repo:** https://github.com/truetruwowng/CICD
# Complete CI/CD Pipeline Setup Guide

## Architecture

```
Developer → Git Push → GitHub Actions (CI) → Build & Push to GHCR
                                                      ↓
                                           ArgoCD watches Git repo
                                                      ↓
                                           Auto-deploy to Kubernetes
```

## Quick Setup

### 1. Run Setup Script

```cmd
scripts\setup-complete-cicd.cmd
```

This will:
- ✅ Install ArgoCD on Kubernetes
- ✅ Get ArgoCD admin password
- ✅ Create GHCR (GitHub Container Registry) secret
- ✅ Update deployment manifests
- ✅ Build and push initial Docker image
- ✅ Deploy ArgoCD application
- ✅ Show you all credentials and next steps

### 2. Push to GitHub

After setup completes:

```cmd
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

### 3. Monitor Pipeline

**GitHub Actions (CI):**
- URL: https://github.com/truetruwowng/CICD/actions
- Watch the build and push process

**ArgoCD UI (CD):**
```cmd
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
- URL: https://localhost:8080
- Username: `admin`
- Password: (provided by setup script)

## How It Works

### CI - GitHub Actions

**Trigger:** Push to `main`, `master`, or `develop` branch

**Steps:**
1. Checkout code
2. Setup Java 21
3. Build Maven package
4. Login to GHCR
5. Build Docker image
6. Push to `ghcr.io/YOUR_USERNAME/sso-k8s`
7. Update `k8s/simple-deployment.yaml` with new image tag
8. Commit and push manifest changes

**Image Tags:**
- `latest` (for main/master branch)
- `main-SHA` (branch + commit SHA)
- `sha-SHA` (commit SHA only)

### CD - ArgoCD

**What ArgoCD Does:**
- ✅ Watches your Git repository
- ✅ Monitors `k8s/simple-deployment.yaml` and `k8s/simple-service.yaml`
- ✅ Automatically syncs changes to Kubernetes
- ✅ Self-heals if someone manually changes resources
- ✅ Prunes deleted resources

**Sync Policy:**
- **Automated**: Changes are deployed automatically
- **Self-Heal**: Manual changes are reverted
- **Prune**: Deleted resources are removed
- **Retry**: Failed deployments retry with backoff

## Workflow Example

1. **Developer makes code changes**
   ```cmd
   # Edit source code
   git add .
   git commit -m "Add new feature"
   git push
   ```

2. **GitHub Actions runs automatically**
   - Builds Maven project
   - Creates Docker image
   - Pushes to GHCR with new tag
   - Updates deployment manifest
   - Commits manifest back to repo

3. **ArgoCD detects manifest change**
   - Sees new image tag in Git
   - Syncs to Kubernetes
   - Performs rolling update
   - New pods start with new image

4. **Zero-downtime deployment**
   - Old pods stay running
   - New pods start and pass health checks
   - Traffic switches to new pods
   - Old pods terminate

## Access Application

```cmd
kubectl port-forward svc/my-sso 8081:8080
```

Open: http://localhost:8081

## Monitoring

### Check ArgoCD Application Status
```cmd
kubectl get applications -n argocd

