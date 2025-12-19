# 🔍 Debug: Credentials Error en GitHub Actions

## ❌ Error

```
Error: Credentials could not be loaded, please check your action inputs: 
Could not load credentials from any providers
```

## 🎯 Diagnóstico Rápido

### Checklist de Verificación

Revisa estos puntos en orden:

#### 1. ✅ Verificar que los Secrets Existen

Ve a tu repositorio en GitHub:
```
https://github.com/bcocbo/TU-REPO/settings/secrets/actions
```

**Debes ver**:
- `AWS_ROLE_ARN` (si usas OIDC)
- O `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` (si usas credenciales temporales)
- `GITOPS_TOKEN`

**Si no están**: Configúralos siguiendo `CONFIGURAR_SECRETS_GITHUB.md`

#### 2. ✅ Verificar el Workflow

El workflow debe tener **permisos de OIDC**:

```yaml
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # ⚠️ CRÍTICO para OIDC
      contents: read
```

#### 3. ✅ Verificar la Configuración de AWS

El step debe estar correctamente configurado:

**Para OIDC**:
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ env.AWS_REGION }}
```

**Para Access Keys**:
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.AWS_REGION }}
```

## 🚀 Soluciones por Escenario

### Escenario A: Estás Usando OIDC

#### Problema 1: Secret AWS_ROLE_ARN no existe

**Verificar**:
```bash
# Ver secrets del repo
gh secret list --repo bcocbo/TU-REPO
```

**Solución**:
```bash
# Agregar el secret
gh secret set AWS_ROLE_ARN --body "arn:aws:iam::226633502530:role/GitHubActionsRole" --repo bcocbo/TU-REPO
```

#### Problema 2: Trust Policy Incorrecta

**Verificar**:
```bash
# Ver trust policy
aws iam get-role --role-name GitHubActionsRole \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].Condition'
```

**Debe mostrar**:
```json
{
  "StringEquals": {
    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
  },
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:bcocbo/*:*"
  }
}
```

**Solución**:
```bash
# Aplicar fix
./fix-oidc-policy.sh GitHubActionsRole
```

#### Problema 3: Permisos de OIDC Faltantes

**Verificar** en `.github/workflows/ci.yaml`:
```yaml
permissions:
  id-token: write  # ⚠️ Debe estar presente
  contents: read
```

**Solución**: Agregar permisos al workflow

#### Problema 4: OIDC Provider No Existe

**Verificar**:
```bash
aws iam list-open-id-connect-providers
```

**Debe mostrar**:
```
arn:aws:iam::226633502530:oidc-provider/token.actions.githubusercontent.com
```

**Solución** (si no existe):
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### Escenario B: Estás Usando Access Keys

#### Problema 1: Secrets No Existen

**Verificar**:
```bash
gh secret list --repo bcocbo/TU-REPO
```

**Debe mostrar**:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Solución**:
```bash
# Agregar secrets
gh secret set AWS_ACCESS_KEY_ID --body "AKIAIOSFODNN7EXAMPLE" --repo bcocbo/TU-REPO
gh secret set AWS_SECRET_ACCESS_KEY --body "wJalrXUtnFEMI/K7MDENG/bPxRfiCY" --repo bcocbo/TU-REPO
```

#### Problema 2: Workflow Configurado para OIDC

**Verificar** en `.github/workflows/ci.yaml`:
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}  # ⚠️ Esto es OIDC
```

**Solución**: Cambiar a access keys:
```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.AWS_REGION }}
```

## 🔧 Fix Rápido: Usar Access Keys Temporalmente

Si necesitas que funcione **ahora mismo**, usa access keys:

### Paso 1: Obtener Credenciales de AWS

```bash
# Opción A: Desde AWS Console
# 1. AWS Console → IAM → Users → Tu usuario
# 2. Security credentials → Create access key
# 3. Copia Access Key ID y Secret Access Key

# Opción B: Desde AWS CLI
aws iam create-access-key --user-name TU-USUARIO
```

### Paso 2: Agregar Secrets a GitHub

```bash
# Reemplaza con tus valores reales
gh secret set AWS_ACCESS_KEY_ID --body "AKIAIOSFODNN7EXAMPLE" --repo bcocbo/TU-REPO
gh secret set AWS_SECRET_ACCESS_KEY --body "wJalrXUtnFEMI/K7MDENG/bPxRfiCY" --repo bcocbo/TU-REPO
```

### Paso 3: Modificar el Workflow

Crea este archivo en tu repo de aplicación: `.github/workflows/ci.yaml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
      - develop

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: mi-app
  GITOPS_REPO: bcocbo/gitops-apps
  APP_NAME: mi-app
  ENVIRONMENT: dev

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and push Docker image
        run: |
          echo "✅ AWS credentials working!"
          echo "Registry: ${{ steps.login-ecr.outputs.registry }}"
```

### Paso 4: Probar

```bash
git add .github/workflows/ci.yaml
git commit -m "fix: Use access keys for AWS auth"
git push origin main
```

## 📊 Tabla de Diagnóstico

| Síntoma | Causa Probable | Solución |
|---------|---------------|----------|
| "Could not load credentials" | Secrets no configurados | Agregar secrets en GitHub |
| "Not authorized to perform sts:AssumeRole" | Trust policy incorrecta | Actualizar trust policy |
| "Invalid identity token" | Permisos OIDC faltantes | Agregar `id-token: write` |
| "OIDC provider not found" | Provider no existe | Crear OIDC provider |
| "Access denied" | Credenciales inválidas | Regenerar credenciales |

## 🧪 Script de Diagnóstico

Crea este archivo `diagnose-workflow.sh`:

```bash
#!/bin/bash

echo "🔍 Diagnóstico de Workflow"
echo "=========================="
echo ""

# Verificar secrets
echo "1. Verificando secrets en GitHub..."
gh secret list --repo bcocbo/TU-REPO

echo ""
echo "2. Verificando OIDC provider en AWS..."
aws iam list-open-id-connect-providers | grep token.actions.githubusercontent.com

echo ""
echo "3. Verificando rol de IAM..."
aws iam get-role --role-name GitHubActionsRole --query 'Role.Arn'

echo ""
echo "4. Verificando trust policy..."
aws iam get-role --role-name GitHubActionsRole \
  --query 'Role.AssumeRolePolicyDocument.Statement[0].Condition'

echo ""
echo "5. Verificando permisos del rol..."
aws iam list-attached-role-policies --role-name GitHubActionsRole

echo ""
echo "✅ Diagnóstico completado"
```

## 💡 Recomendación

**Para resolver rápido**:
1. Usa **access keys** temporalmente (Paso 1-4 arriba)
2. Verifica que funciona
3. Luego migra a OIDC siguiendo `FIX_OIDC_POLICY.md`

**Para producción**:
1. Configura OIDC correctamente
2. Usa la trust policy de `aws-oidc-trust-policy.json`
3. Verifica todos los puntos del checklist

## 🆘 Si Nada Funciona

Comparte estos datos para ayudarte mejor:

```bash
# 1. Secrets configurados
gh secret list --repo bcocbo/TU-REPO

# 2. Contenido del workflow (primeras 50 líneas)
head -50 .github/workflows/ci.yaml

# 3. Logs del workflow
gh run view --repo bcocbo/TU-REPO --log

# 4. Configuración de AWS (si usas OIDC)
aws iam get-role --role-name GitHubActionsRole
```

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Guía de diagnóstico completa
