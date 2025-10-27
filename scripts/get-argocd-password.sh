#!/bin/bash

echo "============================================"
echo "ArgoCD Credentials"
echo "============================================"
echo ""

echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "============================================"
echo "ArgoCD Login Information"
echo "============================================"
echo ""
echo "URL: https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "============================================"
echo ""
echo "To access ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then open: https://localhost:8080"
echo ""

