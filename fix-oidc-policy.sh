#!/bin/bash

# Script para corregir la trust policy de OIDC
# Uso: ./fix-oidc-policy.sh [ROLE_NAME]

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

echo "🔧 Fix OIDC Trust Policy"
echo "========================"
echo ""

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI no está instalado"
    echo ""
    echo "Instala AWS CLI:"
    echo "  macOS:   brew install awscli"
    echo "  Linux:   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Verificar autenticación
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "No estás autenticado en AWS CLI"
    echo ""
    echo "Configura AWS CLI:"
    echo "  aws configure"
    exit 1
fi

# Obtener nombre del rol
ROLE_NAME="${1:-GitHubActionsRole}"

print_info "Rol a actualizar: $ROLE_NAME"
echo ""

# Verificar que el rol existe
if ! aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
    print_error "El rol '$ROLE_NAME' no existe"
    echo ""
    echo "Roles disponibles:"
    aws iam list-roles --query 'Roles[?contains(RoleName, `GitHub`) || contains(RoleName, `Actions`)].RoleName' --output table
    exit 1
fi

# Mostrar política actual
print_info "Política actual:"
echo ""
aws iam get-role --role-name "$ROLE_NAME" \
    --query 'Role.AssumeRolePolicyDocument' \
    --output json | jq '.'

echo ""
print_warning "Esta política será reemplazada con:"
echo ""
cat aws-oidc-trust-policy.json | jq '.'

echo ""
read -p "¿Continuar? (y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    print_info "Operación cancelada"
    exit 0
fi

# Actualizar política
print_info "Actualizando trust policy..."

aws iam update-assume-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-document file://aws-oidc-trust-policy.json

print_success "Trust policy actualizada"

# Verificar
echo ""
print_info "Nueva política:"
echo ""
aws iam get-role --role-name "$ROLE_NAME" \
    --query 'Role.AssumeRolePolicyDocument' \
    --output json | jq '.'

echo ""
print_success "¡Listo!"
echo ""
print_info "Próximos pasos:"
echo "  1. Espera 1-2 minutos para que IAM propague los cambios"
echo "  2. Haz push a tu repositorio para probar"
echo "  3. Verifica que el workflow se ejecuta correctamente"
echo ""
print_info "Ver ARN del rol:"
echo "  aws iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text"
echo ""
print_info "Verificar en GitHub Actions:"
echo "  gh run list --repo bcocbo/TU-REPO"
echo "  gh run view --repo bcocbo/TU-REPO"
