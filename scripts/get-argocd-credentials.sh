#!/bin/bash
# Get ArgoCD Admin Credentials

echo "=================================="
echo "ArgoCD Admin Credentials"
echo "=================================="
echo ""
echo "Username: admin"
echo ""
echo "Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "=================================="
echo "ArgoCD UI Access:"
echo "Run: kubectl -n argocd port-forward svc/argocd-server 8080:443"
echo "Then open: http://localhost:8080"
echo "=================================="

