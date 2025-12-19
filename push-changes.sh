#!/bin/bash

# Script para subir cambios de templates y configuración a GitHub

set -e

echo "🚀 Subiendo cambios a GitHub..."

# Configurar git
git config user.name "Backstage Developer"
git config user.email "dev@backstage.local"

# Agregar archivos modificados
echo "📦 Agregando archivos..."
git add examples/argocd-template/
git add packages/app/src/components/catalog/EntityPage.tsx
git add app-config.yaml
git add catalog-info.yaml

# Verificar que hay cambios
if git diff --cached --quiet; then
    echo "⚠️  No hay cambios para subir"
    exit 0
fi

# Mostrar estado
echo ""
echo "📋 Archivos que se subirán:"
git status --short

echo ""
read -p "¿Continuar con el commit y push? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Cancelado"
    exit 1
fi

# Commit
echo ""
echo "💾 Creando commit..."
git commit -m "feat: Update ArgoCD template and Backstage configuration

- Updated catalog-info.yaml template (removed system reference, fixed ArgoCD URL)
- Disabled ArgoCD plugin (using direct links instead)
- Updated app-config.yaml with ArgoCD configuration
- Fixed template to use microservice.image structure
- Updated catalog-info.yaml for main Backstage component"

# Push
echo ""
echo "⬆️  Subiendo a GitHub..."
git push origin main

echo ""
echo "✅ Cambios subidos exitosamente!"
echo "🔗 Revisa: https://github.com/bcocbo/backstage-app-poc"
