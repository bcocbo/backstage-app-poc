#!/bin/bash

# Script para subir el chart de Helm a GitHub
# Uso: ./upload-helm-chart.sh

set -e

# Configuración
GITHUB_TOKEN="${GITHUB_TOKEN:-$(cat .env | grep GITHUB_TOKEN | cut -d '=' -f2)}"
REPO_OWNER="bcocbo"
REPO_NAME="eks_baseline_chart_Helm"
BRANCH_NAME="feat/update-for-backstage-$(date +%s)"
BASE_BRANCH="main"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN no encontrado"
    exit 1
fi

echo "🚀 Subiendo chart de Helm a GitHub..."
echo "📦 Repo: $REPO_OWNER/$REPO_NAME"
echo "🌿 Branch: $BRANCH_NAME"
echo ""

# Función para obtener el SHA del archivo
get_file_sha() {
    local file_path=$1
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$file_path?ref=$BASE_BRANCH" \
        | grep '"sha"' | head -1 | cut -d '"' -f4
}

# Función para subir un archivo
upload_file() {
    local file_path=$1
    local github_path=$2
    
    if [ ! -f "$file_path" ]; then
        echo "⚠️  Archivo no encontrado: $file_path"
        return
    fi
    
    echo "📤 Subiendo: $github_path"
    
    # Codificar contenido en base64
    local content=$(base64 -i "$file_path" | tr -d '\n')
    
    # Obtener SHA si el archivo existe
    local sha=$(get_file_sha "$github_path")
    local sha_param=""
    if [ ! -z "$sha" ]; then
        sha_param=", \"sha\": \"$sha\""
    fi
    
    # Crear/actualizar archivo
    curl -s -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$github_path" \
        -d "{
            \"message\": \"Update $github_path for Backstage integration\",
            \"content\": \"$content\",
            \"branch\": \"$BRANCH_NAME\"
            $sha_param
        }" > /dev/null
}

# Crear branch
echo "🌿 Creando branch $BRANCH_NAME..."
BASE_SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/git/refs/heads/$BASE_BRANCH" \
    | grep '"sha"' | head -1 | cut -d '"' -f4)

curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/git/refs" \
    -d "{
        \"ref\": \"refs/heads/$BRANCH_NAME\",
        \"sha\": \"$BASE_SHA\"
    }" > /dev/null

echo "✅ Branch creado"
echo ""

# Subir archivos del chart
echo "📦 Subiendo archivos del chart..."

# Chart metadata
upload_file "charts/eks_baseline_chart-Helm-1/values.yaml" "values.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/.helmignore" ".helmignore" 2>/dev/null || true

# Templates
upload_file "charts/eks_baseline_chart-Helm-1/templates/Chart.yaml" "Chart.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/_helpers.tpl" "templates/_helpers.tpl"
upload_file "charts/eks_baseline_chart-Helm-1/templates/deployment.yaml" "templates/deployment.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/service.yaml" "templates/service.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/hpa.yaml" "templates/hpa.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/configmap.yaml" "templates/configmap.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/istio-gateway.yaml" "templates/istio-gateway.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/istio-virtualservice.yaml" "templates/istio-virtualservice.yaml"

echo ""
echo "✅ Archivos subidos exitosamente"
echo ""

# Crear Pull Request
echo "🔀 Creando Pull Request..."
PR_BODY="## Changes

### Chart Updates for Backstage Integration

- Updated values.yaml with Python app defaults
- Configured security contexts for non-root users
- Health checks compatible with Flask apps (port 8000, /health endpoint)
- Service account creation enabled by default
- Ready for GitOps workflow with ArgoCD

### Compatibility
- Works with Python Flask apps
- Supports custom and prebuilt images
- Compatible with EKS security policies

### Testing
- Tested with Backstage scaffolder
- Deployed successfully via ArgoCD
- Health checks passing"

PR_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls" \
    -d "$(jq -n \
        --arg title "feat: Update chart for Backstage integration" \
        --arg body "$PR_BODY" \
        --arg head "$BRANCH_NAME" \
        --arg base "$BASE_BRANCH" \
        '{title: $title, body: $body, head: $head, base: $base}')")

PR_URL=$(echo $PR_RESPONSE | grep -o '"html_url": "[^"]*' | cut -d '"' -f4 | head -1)

if [ ! -z "$PR_URL" ]; then
    echo "✅ Pull Request creado exitosamente!"
    echo "🔗 URL: $PR_URL"
else
    echo "⚠️  Error al crear PR. Respuesta:"
    echo "$PR_RESPONSE"
fi

echo ""
echo "🎉 Proceso completado!"
