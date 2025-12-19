#!/bin/bash

# Script para subir cambios del scaffolder a GitHub usando la API
# Uso: ./upload-to-github.sh

set -e

# Configuración
GITHUB_TOKEN="${GITHUB_TOKEN:-$(cat .env | grep GITHUB_TOKEN | cut -d '=' -f2)}"
REPO_OWNER="bcocbo"
REPO_NAME="backstage-app-poc"
BRANCH_NAME="feat/complete-gitops-workflow-$(date +%s)"
BASE_BRANCH="main"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN no encontrado"
    echo "Configura la variable de entorno o agrégala al .env"
    exit 1
fi

echo "🚀 Subiendo cambios del scaffolder a GitHub..."
echo "📦 Repo: $REPO_OWNER/$REPO_NAME"
echo "🌿 Branch: $BRANCH_NAME"
echo ""

# Función para obtener el SHA del archivo en GitHub
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
    local content=$(base64 -i "$file_path")
    
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
            \"message\": \"Update $github_path\",
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

# Lista de archivos a subir
echo "📦 Subiendo archivos del template..."

# Template principal
upload_file "examples/argocd-template/template.yaml" "examples/argocd-template/template.yaml"

# Archivos de contenido
upload_file "examples/argocd-template/content/Dockerfile" "examples/argocd-template/content/Dockerfile"
upload_file "examples/argocd-template/content/.github/workflows/ci.yaml" "examples/argocd-template/content/.github/workflows/ci.yaml"
upload_file "examples/argocd-template/content/catalog-info.yaml" "examples/argocd-template/content/catalog-info.yaml"
upload_file "examples/argocd-template/content/README.md" "examples/argocd-template/content/README.md"

# Archivos Python
upload_file "examples/argocd-template/content-python/app.py" "examples/argocd-template/content-python/app.py"
upload_file "examples/argocd-template/content-python/requirements.txt" "examples/argocd-template/content-python/requirements.txt"
upload_file "examples/argocd-template/content-python/healthcheck.py" "examples/argocd-template/content-python/healthcheck.py"

# GitOps values (usando comillas simples para evitar expansión de variables)
upload_file 'examples/argocd-template/gitops-values/values/${{ values.environment }}/${{ values.name }}/values.yaml' 'examples/argocd-template/gitops-values/values/${{ values.environment }}/${{ values.name }}/values.yaml'
upload_file 'examples/argocd-template/gitops-values/argocd/applications/${{ values.environment }}/${{ values.name }}.yaml' 'examples/argocd-template/gitops-values/argocd/applications/${{ values.environment }}/${{ values.name }}.yaml'

echo ""
echo "✅ Archivos subidos exitosamente"
echo ""

# Crear Pull Request
echo "🔀 Creando Pull Request..."
PR_BODY="## Changes

### Template Improvements
- Fixed Dockerfile for Python apps (correct PATH for dependencies)
- Configured health checks for port 8000 and /health endpoint
- Updated to use publish:github:pull-request for GitOps repo
- Compatible with eks_baseline_chart_Helm

### ArgoCD Integration
- Fixed multiple sources syntax in Application manifests
- Correct valueFiles reference
- App-of-Apps pattern ready

### CI/CD Workflow
- Auto-create ECR repositories if they don't exist
- Create PR in GitOps repo with updated image tags
- Ignore paths to prevent build loops

## Testing
- Tested with Python Flask apps
- ArgoCD syncing from GitOps repo
- CI/CD workflow creating images and PRs"

PR_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls" \
    -d "$(jq -n \
        --arg title "feat: Complete GitOps workflow with ArgoCD integration" \
        --arg body "$PR_BODY" \
        --arg head "$BRANCH_NAME" \
        --arg base "$BASE_BRANCH" \
        '{title: $title, body: $body, head: $head, base: $base}')")

PR_URL=$(echo $PR_RESPONSE | grep -o '"html_url": "[^"]*' | cut -d '"' -f4)

if [ ! -z "$PR_URL" ]; then
    echo "✅ Pull Request creado exitosamente!"
    echo "🔗 URL: $PR_URL"
else
    echo "⚠️  Error al crear PR. Respuesta:"
    echo "$PR_RESPONSE"
fi

echo ""
echo "🎉 Proceso completado!"
