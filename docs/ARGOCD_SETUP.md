Argo CD setup and integration with GitHub Actions

This guide explains how to install Argo CD locally (Docker Desktop's Kubernetes), create an Argo CD Application that points to this repository, and connect it to the GitHub Actions workflow which updates `k8s/app-deployment.yaml`.

1) Install Argo CD in your cluster

Open a terminal (Windows cmd/powershell) and run:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

2) Expose the Argo CD API server (for local testing)

You can port-forward the server UI to access it locally:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Then open: http://localhost:8080

Default admin password (one-time):

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

3) Create the Argo CD Application for this repo

Edit `k8s/argocd-app.yaml` and replace `repoURL` with your GitHub repo HTTPS URL (for example `https://github.com/my-org/my-repo`). Then apply:

```bash
kubectl apply -f k8s/argocd-app.yaml -n argocd
```

Argo CD will now watch the `k8s` folder in your repo and sync changes to the cluster automatically (because `syncPolicy.automated` is enabled).

4) Configure GitHub Actions (CI)

The repository already contains a workflow at `.github/workflows/ci-cd.yaml` that builds and pushes a Docker image to GitHub Container Registry (`ghcr.io`) and updates `k8s/app-deployment.yaml` with the new image tag, then commits the change back to the repo. Argo CD will detect the change and deploy it.

Make sure:
- The workflow has permission to push to the repository. In the repository settings -> Actions -> General, set "Allow GitHub Actions to create and approve pull requests" if needed. The workflow uses `permissions: contents: write`.
- If you prefer Docker Hub or another registry, update the workflow's login and image name accordingly, and add the required secrets (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, etc.).

5) Notes and troubleshooting

- If Argo CD doesn't sync, open the Argo CD UI and check the app's sync and health status; the events will show what failed.
- Make sure your `k8s` manifests are valid and do not require cluster-level resources you don't have permission for.
- For production, lock down repository permissions and use a dedicated machine account or deploy keys instead of relying on `GITHUB_TOKEN` for pushes.

6) Local test: trigger workflow and observe

- Push a change to `main` (or create a commit/PR) to trigger the workflow. It will build and push an image and update `k8s/app-deployment.yaml`.
- In Argo CD UI, you should see the Application register a change and automatically sync it (if automated sync is enabled). If not, you can manually press "Sync" in the UI.

If you want, I can now:
- Create a small example change to `k8s/app-deployment.yaml` to simulate a CI update.
- Help you adapt the workflow to Docker Hub instead of GHCR.
- Walk you through installing Argo CD and creating the application step-by-step on your machine.

