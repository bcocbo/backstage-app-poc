# 🔐 Configurar Secrets de GitHub para CI/CD

## Error Actual

```
Error: Credentials could not be loaded, please check your action inputs: 
Could not load credentials from any providers
```

Este error ocurre porque el workflow necesita credenciales de AWS que deben configurarse como **GitHub Secrets**.

## 📋 Secrets Requeridos

Tu workflow necesita **2 secrets**:

| Secret | Descripción | Ejemplo |
|--------|-------------|---------|
| `AWS_ROLE_ARN` | ARN del rol de AWS para OIDC | `arn:aws:iam::123456789012:role/GitHubActionsRole` |
| `GITOPS_TOKEN` | Token de GitHub con permisos de repo | `ghp_xxxxxxxxxxxxxxxxxxxx` |

---

## 🚀 Opción 1: Credenciales Temporales (Rápido)

Si solo quieres probar rápidamente, puedes usar credenciales temporales de AWS:

### Paso 1: Obtener Credenciales Temporales de AWS

```bash
# Opción A: Desde AWS Console
# 1. Ve a AWS Console → IAM → Users → Tu usuario
# 2. Security credentials → Create access key
# 3. Selecciona "Command Line Interface (CLI)"
# 4. Copia Access Key ID y Secret Access Key

# Opción B: Desde AWS CLI (si ya tienes configurado)
aws sts get-session-token --duration-seconds 3600
```

### Paso 2: Configurar Secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (⚙️)
3. En el menú lateral, click en **Secrets and variables** → **Actions**
4. Click en **New repository secret**

Agrega estos 3 secrets:

**Secret 1: `AWS_ACCESS_KEY_ID`**
```
Nombre: AWS_ACCESS_KEY_ID
Valor: AKIAIOSFODNN7EXAMPLE
```

**Secret 2: `AWS_SECRET_ACCESS_KEY`**
```
Nombre: AWS_SECRET_ACCESS_KEY
Valor: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Secret 3: `GITOPS_TOKEN`**
```
Nombre: GITOPS_TOKEN
Valor: ghp_xxxxxxxxxxxxxxxxxxxx
```

### Paso 3: Modificar el Workflow Temporalmente

Edita `.github/workflows/ci.yaml` en tu repositorio de aplicación:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    # TEMPORAL: Usar access keys en lugar de OIDC
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.AWS_REGION }}
    # Comentar esta línea temporalmente:
    # role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
```

### ⚠️ Importante

- Las credenciales temporales expiran (típicamente en 1-12 horas)
- **NO uses esto en producción** - solo para pruebas
- Después de probar, configura OIDC (Opción 2)

---

## 🔒 Opción 2: OIDC (Recomendado para Producción)

OIDC es más seguro porque no requiere almacenar credenciales de larga duración.

### Paso 1: Crear Identity Provider en AWS

```bash
# 1. Ve a AWS Console → IAM → Identity providers
# 2. Click "Add provider"
# 3. Selecciona "OpenID Connect"
# 4. Configura:

Provider URL: https://token.actions.githubusercontent.com
Audience: sts.amazonaws.com
```

O usando AWS CLI:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### Paso 2: Crear Rol de IAM

Crea un archivo `trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::TU_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:bcocbo/*:*"
        }
      }
    }
  ]
}
```

Crea el rol:

```bash
# Crear rol
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://trust-policy.json

# Adjuntar política para ECR
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser

# Obtener ARN del rol
aws iam get-role --role-name GitHubActionsRole --query 'Role.Arn' --output text
```

### Paso 3: Configurar Secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. New repository secret

**Secret 1: `AWS_ROLE_ARN`**
```
Nombre:AWS_ROLE_ARN 
Valor: arn:aws:iam::123456789012:role/GitHubActionsRole
```

**Secret 2: `GITOPS_TOKEN`**
```
Nombre: GITOPS_TOKEN
Valor: ghp_xxxxxxxxxxxxxxxxxxxx
```

### Paso 4: Verificar el Workflow

El workflow ya está configurado para OIDC:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ env.AWS_REGION }}
```

---

## 🔑 Crear Token de GitHub (GITOPS_TOKEN)

### Paso 1: Generar Token

1. Ve a GitHub → Settings (tu perfil, no el repo)
2. Developer settings → Personal access tokens → Tokens (classic)
3. Generate new token (classic)
4. Configura:
   - **Note**: `GitOps Automation`
   - **Expiration**: 90 days (o lo que prefieras)
   - **Scopes**: Selecciona:
     - ✅ `repo` (Full control of private repositories)
     - ✅ `workflow` (Update GitHub Action workflows)

5. Click **Generate token**
6. **Copia el token** (solo se muestra una vez)

### Paso 2: Agregar a GitHub Secrets

1. Ve a tu repositorio de aplicación
2. Settings → Secrets and variables → Actions
3. New repository secret
4. Nombre: `GITOPS_TOKEN`
5. Valor: Pega el token que copiaste

---

## 🧪 Probar la Configuración

### Opción A: Push Manual

```bash
# En tu repositorio de aplicación
git add .
git commit -m "test: Trigger CI/CD"
git push origin main
```

### Opción B: Workflow Dispatch

1. Ve a tu repo → Actions
2. Selecciona el workflow "CI/CD Pipeline"
3. Click "Run workflow"
4. Selecciona branch y click "Run workflow"

### Verificar Logs

1. Ve a Actions en tu repositorio
2. Click en el workflow que se está ejecutando
3. Revisa cada step:
   - ✅ Configure AWS credentials
   - ✅ Login to Amazon ECR
   - ✅ Build and push Docker image
   - ✅ Update GitOps repository

---

## 🐛 Troubleshooting

### Error: "Credentials could not be loaded"

**Causa**: Secrets no configurados o mal configurados

**Solución**:
```bash
# Verifica que los secrets existan
# Settings → Secrets and variables → Actions
# Deberías ver:
# - AWS_ROLE_ARN (o AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY)
# - GITOPS_TOKEN
```

### Error: "User is not authorized to perform: sts:AssumeRoleWithWebIdentity"

**Causa**: Trust policy del rol no permite GitHub Actions

**Solución**:
```bash
# Verifica el trust policy
aws iam get-role --role-name GitHubActionsRole --query 'Role.AssumeRolePolicyDocument'

# Debe incluir:
# - Principal.Federated: arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com
# - Condition con token.actions.githubusercontent.com:sub
```

### Error: "Access denied to ECR"

**Causa**: Rol no tiene permisos de ECR

**Solución**:
```bash
# Adjuntar política de ECR
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
```

### Error: "Repository not found" (GitOps)

**Causa**: Token no tiene permisos o repo no existe

**Solución**:
1. Verifica que el token tenga scope `repo`
2. Verifica que el repo `bcocbo/gitops-apps` exista
3. Verifica que el token tenga acceso al repo

---

## 📝 Checklist de Configuración

### Para Pruebas Rápidas (Opción 1)

- [ ] Obtener credenciales temporales de AWS
- [ ] Agregar `AWS_ACCESS_KEY_ID` a GitHub Secrets
- [ ] Agregar `AWS_SECRET_ACCESS_KEY` a GitHub Secrets
- [ ] Crear token de GitHub con scope `repo`
- [ ] Agregar `GITOPS_TOKEN` a GitHub Secrets
- [ ] Modificar workflow para usar access keys
- [ ] Hacer push y verificar que funciona

### Para Producción (Opción 2)

- [ ] Crear OIDC provider en AWS
- [ ] Crear rol de IAM con trust policy
- [ ] Adjuntar política de ECR al rol
- [ ] Obtener ARN del rol
- [ ] Agregar `AWS_ROLE_ARN` a GitHub Secrets
- [ ] Crear token de GitHub con scope `repo`
- [ ] Agregar `GITOPS_TOKEN` a GitHub Secrets
- [ ] Verificar que workflow usa OIDC
- [ ] Hacer push y verificar que funciona

---

## 🔗 Referencias

- [GitHub Actions - AWS Credentials](https://github.com/aws-actions/configure-aws-credentials)
- [AWS - OIDC with GitHub Actions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [GitHub - Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

---

## 💡 Recomendación

**Para empezar rápido**: Usa la Opción 1 (credenciales temporales)

**Para producción**: Migra a la Opción 2 (OIDC) lo antes posible

**Ventajas de OIDC**:
- ✅ No almacena credenciales de larga duración
- ✅ Más seguro
- ✅ No expira (mientras el rol exista)
- ✅ Mejor auditoría
- ✅ Recomendado por AWS y GitHub

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Guía completa para configuración de secrets
