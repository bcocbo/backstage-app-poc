#!/bin/bash

# Script para ayudar a configurar GitHub Secrets para CI/CD
# Uso: ./setup-github-secrets.sh

set -e

echo "🔐 Configuración de GitHub Secrets para CI/CD"
echo "=============================================="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar si gh CLI está instalado
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) no está instalado"
    echo ""
    echo "Instala GitHub CLI:"
    echo "  macOS:   brew install gh"
    echo "  Linux:   https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo "  Windows: https://github.com/cli/cli/releases"
    echo ""
    echo "O configura los secrets manualmente en:"
    echo "  https://github.com/TU_USUARIO/TU_REPO/settings/secrets/actions"
    exit 1
fi

# Verificar autenticación
if ! gh auth status &> /dev/null; then
    print_warning "No estás autenticado en GitHub CLI"
    echo ""
    print_info "Ejecuta: gh auth login"
    exit 1
fi

echo ""
print_info "Selecciona el método de autenticación con AWS:"
echo ""
echo "1) Credenciales temporales (rápido, para pruebas)"
echo "2) OIDC (recomendado para producción)"
echo ""
read -p "Selecciona una opción (1 o 2): " auth_method

echo ""

if [ "$auth_method" == "1" ]; then
    # Opción 1: Credenciales temporales
    print_info "Configurando credenciales temporales de AWS"
    echo ""
    
    print_warning "Necesitarás:"
    echo "  - AWS Access Key ID"
    echo "  - AWS Secret Access Key"
    echo ""
    echo "Obtén estas credenciales desde:"
    echo "  AWS Console → IAM → Users → Tu usuario → Security credentials → Create access key"
    echo ""
    
    read -p "AWS Access Key ID: " aws_access_key_id
    read -sp "AWS Secret Access Key: " aws_secret_access_key
    echo ""
    
    if [ -z "$aws_access_key_id" ] || [ -z "$aws_secret_access_key" ]; then
        print_error "Credenciales de AWS no pueden estar vacías"
        exit 1
    fi
    
    # Configurar secrets
    print_info "Configurando secrets en GitHub..."
    
    read -p "Nombre del repositorio (ej: bcocbo/my-app): " repo_name
    
    if [ -z "$repo_name" ]; then
        print_error "Nombre del repositorio no puede estar vacío"
        exit 1
    fi
    
    gh secret set AWS_ACCESS_KEY_ID --body "$aws_access_key_id" --repo "$repo_name"
    gh secret set AWS_SECRET_ACCESS_KEY --body "$aws_secret_access_key" --repo "$repo_name"
    
    print_success "Credenciales de AWS configuradas"
    
elif [ "$auth_method" == "2" ]; then
    # Opción 2: OIDC
    print_info "Configurando OIDC con AWS"
    echo ""
    
    print_warning "Primero debes configurar OIDC en AWS:"
    echo ""
    echo "1. Crear OIDC Provider:"
    echo "   aws iam create-open-id-connect-provider \\"
    echo "     --url https://token.actions.githubusercontent.com \\"
    echo "     --client-id-list sts.amazonaws.com \\"
    echo "     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1"
    echo ""
    echo "2. Crear rol de IAM (ver CONFIGURAR_SECRETS_GITHUB.md)"
    echo ""
    
    read -p "ARN del rol de AWS (ej: arn:aws:iam::123456789012:role/GitHubActionsRole): " aws_role_arn
    
    if [ -z "$aws_role_arn" ]; then
        print_error "ARN del rol no puede estar vacío"
        exit 1
    fi
    
    # Configurar secret
    print_info "Configurando secret en GitHub..."
    
    read -p "Nombre del repositorio (ej: bcocbo/my-app): " repo_name
    
    if [ -z "$repo_name" ]; then
        print_error "Nombre del repositorio no puede estar vacío"
        exit 1
    fi
    
    gh secret set AWS_ROLE_ARN --body "$aws_role_arn" --repo "$repo_name"
    
    print_success "ARN del rol configurado"
    
else
    print_error "Opción inválida"
    exit 1
fi

# Configurar GITOPS_TOKEN
echo ""
print_info "Configurando token de GitHub para GitOps"
echo ""

print_warning "Necesitas un Personal Access Token con permisos:"
echo "  - repo (Full control of private repositories)"
echo "  - workflow (Update GitHub Action workflows)"
echo ""
echo "Crea uno en: https://github.com/settings/tokens/new"
echo ""

read -sp "GitHub Token (ghp_...): " gitops_token
echo ""

if [ -z "$gitops_token" ]; then
    print_error "Token de GitHub no puede estar vacío"
    exit 1
fi

gh secret set GITOPS_TOKEN --body "$gitops_token" --repo "$repo_name"

print_success "Token de GitOps configurado"

# Resumen
echo ""
echo "=============================================="
print_success "Configuración completada!"
echo "=============================================="
echo ""
print_info "Secrets configurados en: $repo_name"
echo ""

if [ "$auth_method" == "1" ]; then
    echo "  ✅ AWS_ACCESS_KEY_ID"
    echo "  ✅ AWS_SECRET_ACCESS_KEY"
    echo "  ✅ GITOPS_TOKEN"
    echo ""
    print_warning "Recuerda: Las credenciales temporales expiran"
    print_warning "Para producción, migra a OIDC (Opción 2)"
else
    echo "  ✅ AWS_ROLE_ARN"
    echo "  ✅ GITOPS_TOKEN"
fi

echo ""
print_info "Próximos pasos:"
echo "  1. Haz push a tu repositorio para activar el workflow"
echo "  2. Ve a Actions para ver el progreso"
echo "  3. Verifica que el workflow se ejecuta correctamente"
echo ""
echo "Ver logs:"
echo "  gh run list --repo $repo_name"
echo "  gh run view --repo $repo_name"
echo ""
print_success "¡Listo para CI/CD! 🚀"
