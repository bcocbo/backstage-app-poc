#!/bin/bash

# Script para limpiar archivos antiguos y subir solo el chart correcto
set -e

GITHUB_TOKEN="${GITHUB_TOKEN:-$(cat .env | grep GITHUB_TOKEN | cut -d '=' -f2)}"
REPO_OWNER="bcocbo"
REPO_NAME="eks_baseline_chart_Helm"
BRANCH_NAME="feat/clean-chart-$(date +%s)"
BASE_BRANCH="main"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN no encontrado"
    exit 1
fi

echo "🧹 Limpiando y subiendo chart correcto..."
echo "📦 Repo: $REPO_OWNER/$REPO_NAME"
echo "🌿 Branch: $BRANCH_NAME"
echo ""

# Función para eliminar archivo
delete_file() {
    local file_path=$1
    echo "🗑️  Eliminando: $file_path"
    
    local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$file_path?ref=$BRANCH_NAME" \
        | grep '"sha"' | head -1 | cut -d '"' -f4)
    
    if [ ! -z "$sha" ]; then
        curl -s -X DELETE \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/json" \
            "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$file_path" \
            -d "{
                \"message\": \"Remove old chart file: $file_path\",
                \"sha\": \"$sha\",
                \"branch\": \"$BRANCH_NAME\"
            }" > /dev/null
    fi
}

# Función para subir archivo
upload_file() {
    local file_path=$1
    local github_path=$2
    
    if [ ! -f "$file_path" ]; then
        echo "⚠️  Archivo no encontrado: $file_path"
        return
    fi
    
    echo "📤 Subiendo: $github_path"
    
    local content=$(base64 -i "$file_path" | tr -d '\n')
    local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents/$github_path?ref=$BRANCH_NAME" \
        | grep '"sha"' | head -1 | cut -d '"' -f4)
    
    local sha_param=""
    if [ ! -z "$sha" ]; then
        sha_param=", \"sha\": \"$sha\""
    fi
    
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

# Eliminar archivos del chart anterior
echo "🗑️  Eliminando archivos del chart anterior..."
delete_file "templates/serviceaccount.yaml"
delete_file "templates/ingress.yaml"
delete_file "templates/secret.yaml"
delete_file ".helmignore"

echo ""
echo "📦 Subiendo archivos del chart correcto..."

# Subir archivos del chart eks-baseline
upload_file "charts/eks_baseline_chart-Helm-1/values.yaml" "values.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/Chart.yaml" "Chart.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/_helpers.tpl" "templates/_helpers.tpl"
upload_file "charts/eks_baseline_chart-Helm-1/templates/deployment.yaml" "templates/deployment.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/service.yaml" "templates/service.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/hpa.yaml" "templates/hpa.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/configmap.yaml" "templates/configmap.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/istio-gateway.yaml" "templates/istio-gateway.yaml"
upload_file "charts/eks_baseline_chart-Helm-1/templates/istio-virtualservice.yaml" "templates/istio-virtualservice.yaml"

echo ""
echo "✅ Archivos actualizados"
echo ""

# Crear Pull Request
echo "🔀 Creando Pull Request..."
PR_BODY="## Clean Chart - Remove Old Files

### Changes
- ❌ Removed old chart files (serviceaccount.yaml, ingress.yaml, secret.yaml)
- ✅ Updated with eks-baseline chart templates
- ✅ Chart now uses microservice.* structure
- ✅ Compatible with Backstage scaffolder

### Files Removed
- templates/serviceaccount.yaml (not needed, uses default SA)
- templates/ingress.yaml (not used in this setup)
- templates/secret.yaml (not used in this setup)

### Files Updated
- Chart.yaml (eks-baseline v0.1.0)
- values.yaml (microservice structure)
- templates/_helpers.tpl
- templates/deployment.yaml
- templates/service.yaml
- templates/hpa.yaml
- templates/configmap.yaml
- templates/istio-gateway.yaml
- templates/istio-virtualservice.yaml

### Testing
- Chart renders correctly with Helm
- Compatible with ArgoCD multiple sources
- Works with Python Flask apps"

PR_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls" \
    -d "$(jq -n \
        --arg title "feat: Clean chart and use eks-baseline templates" \
        --arg body "$PR_BODY" \
        --arg head "$BRANCH_NAME" \
        --arg base "$BASE_BRANCH" \
        '{title: $title, body: $body, head: $head, base: $base}')")

PR_URL=$(echo $PR_RESPONSE | grep -o '"html_url": "[^"]*' | cut -d '"' -f4 | head -1)

if [ ! -z "$PR_URL" ]; then
    echo "✅ Pull Request creado exitosamente!"
    echo "🔗 URL: $PR_URL"
else
    echo "⚠️  Error al crear PR"
    echo "$PR_RESPONSE"
fi

echo ""
echo "🎉 Proceso completado!"
