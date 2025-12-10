#!/bin/bash

# Script para configurar ArgoCD en tu cluster de Kubernetes
# Uso: ./setup-argocd.sh

set -e

echo "🚀 Instalando ArgoCD..."

# Crear namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Instalar ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Esperando a que ArgoCD esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Obtener la contraseña inicial
echo ""
echo "✅ ArgoCD instalado correctamente!"
echo ""
echo "📝 Credenciales de acceso:"
echo "   Usuario: admin"
echo "   Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
echo ""
echo "🌐 Para acceder a la UI de ArgoCD, ejecuta:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "   Luego visita: https://localhost:8080"
echo ""
echo "💡 Para instalar el CLI de ArgoCD:"
echo "   # macOS"
echo "   brew install argocd"
echo ""
echo "   # Linux"
echo "   curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
echo "   chmod +x /usr/local/bin/argocd"
echo ""
echo "🔐 Para hacer login con el CLI:"
echo "   argocd login localhost:8080"
echo ""
