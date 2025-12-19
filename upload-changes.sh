#!/bin/bash

# Script para subir cambios a GitHub excluyendo documentación

set -e

echo "🚀 Subiendo cambios a GitHub (excluyendo documentación)..."

# Configurar git
git config user.name "Backstage Developer"
git config user.email "dev@backstage.local"

# Agregar todos los archivos excepto .md
echo "📦 Agregando archivos..."

# Agregar archivos específicos importantes
git add examples/argocd-template/
git add charts/
git add packages/
git add plugins/
git add app-config.yaml
git add app-config.production.yaml
git add package.json
git add tsconfig.json
git add Dockerfile
git add .github/
git add .dockerignore
git add .gitignore
git add .eslintrc.js
git add .prettierignore
git add playwright.config.ts
git add backstage.json
git add catalog-info.yaml

# Excluir explícitamente archivos .md
git reset -- '*.md'
git reset -- 'docs/*.md'
git reset -- '.kiro/specs/**/*.md'

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
git commit -m "feat: Update Backstage templates and configuration

- Updated ArgoCD template with microservice.image support
- Fixed CI/CD workflow for ECR and GitOps integration
- Updated Helm chart to eks_baseline_chart-Helm-1
- Configured ArgoCD plugin in Backstage
- Excluded documentation files from this commit"

# Push
echo ""
echo "⬆️  Subiendo a GitHub..."
git push origin main

echo ""
echo "✅ Cambios subidos exitosamente!"
echo "🔗 Revisa: https://github.com/bcocbo/backstage-app-poc"
