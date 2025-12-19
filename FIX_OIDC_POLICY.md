# 🔧 Fix: OIDC Trust Policy Error

## ❌ Error Actual

```
Assuming role with OIDC
Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity
```

## 🔍 Causa del Problema

Tu trust policy actual está **demasiado restrictiva**:

```json
{
  "token.actions.githubusercontent.com:sub": "repo:bcocbo/gitops-apps:ref:refs/heads/main"
}
```

Esto solo permite:
- ✅ Repositorio: `bcocbo/gitops-apps`
- ✅ Rama: `main`

Pero el workflow se ejecuta desde:
- ❌ Repositorio: `bcocbo/MI-APP` (tu aplicación)
- ❌ Rama: `main`, `develop`, etc.

## ✅ Solución

### Opción 1: Permitir Todos los Repos de bcocbo (Recomendado)

Esta es la mejor opción si todos tus repositorios bajo `bcocbo` necesitan acceso a AWS:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::226633502530:oidc-provider/token.actions.githubusercontent.com"
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

**Cambios**:
- `repo:bcocbo/gitops-apps:ref:refs/heads/main` → `repo:bcocbo/*:*`
- Permite cualquier repo bajo `bcocbo`
- Permite cualquier rama

### Opción 2: Permitir Solo Repos Específicos

Si quieres más control, lista los repos específicos:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::226633502530:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:bcocbo/my-app:*",
            "repo:bcocbo/another-app:*",
            "repo:bcocbo/gitops-apps:*"
          ]
        }
      }
    }
  ]
}
```

### Opción 3: Permitir Solo Ramas Específicas

Si quieres restringir a ciertas ramas:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::226633502530:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:bcocbo/*:ref:refs/heads/main",
            "repo:bcocbo/*:ref:refs/heads/develop"
          ]
        }
      }
    }
  ]
}
```

## 🚀 Aplicar la Solución

### Método 1: AWS Console (Más Fácil)

1. Ve a **AWS Console** → **IAM** → **Roles**
2. Busca tu rol (ej: `GitHubActionsRole`)
3. Click en la pestaña **Trust relationships**
4. Click en **Edit trust policy**
5. Reemplaza el JSON con la nueva política (Opción 1 recomendada)
6. Click **Update policy**

### Método 2: AWS CLI

```bash
# Guardar la nueva política en un archivo
cat > trust-policy-fixed.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::226633502530:oidc-provider/token.actions.githubusercontent.com"
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
EOF

# Actualizar el rol
aws iam update-assume-role-policy \
  --role-name GitHubActionsRole \
  --policy-document file://trust-policy-fixed.json

# Verificar
aws iam get-role --role-name GitHubActionsRole \
  --query 'Role.AssumeRolePolicyDocument' \
  --output json
```

## 🧪 Verificar la Solución

### 1. Verificar la Política

```bash
# Ver la trust policy actual
aws iam get-role --role-name GitHubActionsRole \
  --query 'Role.AssumeRolePolicyDocument' \
  --output json
```

Deberías ver:
```json
{
  "token.actions.githubusercontent.com:sub": "repo:bcocbo/*:*"
}
```

### 2. Probar el Workflow

```bash
# En tu repositorio de aplicación
git add .
git commit -m "test: Verify OIDC fix"
git push origin main
```

### 3. Ver Logs

```bash
# Ver workflows recientes
gh run list --repo bcocbo/MI-APP

# Ver detalles del último run
gh run view --repo bcocbo/MI-APP
```

## 📊 Comparación de Políticas

| Política | Permite | Seguridad | Recomendado |
|----------|---------|-----------|-------------|
| `repo:bcocbo/gitops-apps:ref:refs/heads/main` | Solo gitops-apps en main | 🔒 Muy alta | ❌ Demasiado restrictivo |
| `repo:bcocbo/*:*` | Todos los repos de bcocbo | 🔒 Alta | ✅ Recomendado |
| `repo:bcocbo/*:ref:refs/heads/main` | Todos los repos, solo main | 🔒 Muy alta | ⚠️ Si solo usas main |
| `repo:*/*:*` | Cualquier repo de GitHub | ⚠️ Baja | ❌ No recomendado |

## 🔍 Entendiendo el Subject (sub)

El `sub` claim en el token OIDC tiene este formato:

```
repo:OWNER/REPO:ref:refs/heads/BRANCH
```

Ejemplos:
- `repo:bcocbo/my-app:ref:refs/heads/main`
- `repo:bcocbo/my-app:ref:refs/heads/develop`
- `repo:bcocbo/another-app:ref:refs/heads/main`

Wildcards:
- `repo:bcocbo/*:*` - Cualquier repo de bcocbo, cualquier rama
- `repo:bcocbo/my-app:*` - Solo my-app, cualquier rama
- `repo:bcocbo/*:ref:refs/heads/main` - Cualquier repo, solo main

## 🐛 Troubleshooting

### Error persiste después de actualizar

**Causa**: Cache de IAM

**Solución**: Espera 1-2 minutos y vuelve a intentar

### Error: "Federated not found"

**Causa**: OIDC provider no existe

**Solución**:
```bash
# Verificar que el provider existe
aws iam list-open-id-connect-providers

# Debería mostrar:
# arn:aws:iam::226633502530:oidc-provider/token.actions.githubusercontent.com
```

### Error: "Invalid identity token"

**Causa**: Token expirado o inválido

**Solución**: El workflow genera un nuevo token automáticamente, solo vuelve a ejecutar

## 💡 Mejores Prácticas

### 1. Usa Wildcards Apropiados

✅ **Bueno**:
```json
"token.actions.githubusercontent.com:sub": "repo:bcocbo/*:*"
```

❌ **Malo** (demasiado permisivo):
```json
"token.actions.githubusercontent.com:sub": "repo:*/*:*"
```

### 2. Limita por Organización

Si tienes una organización:
```json
"token.actions.githubusercontent.com:sub": "repo:MI-ORG/*:*"
```

### 3. Usa Múltiples Roles

Para diferentes niveles de acceso:
- `GitHubActionsRole-Dev` - Para repos de desarrollo
- `GitHubActionsRole-Prod` - Para repos de producción

### 4. Audita Regularmente

```bash
# Ver quién está usando el rol
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=GitHubActionsRole \
  --max-results 50
```

## 📝 Checklist

- [ ] Actualizar trust policy con `repo:bcocbo/*:*`
- [ ] Verificar que la política se actualizó correctamente
- [ ] Esperar 1-2 minutos para que IAM propague los cambios
- [ ] Hacer push al repositorio de aplicación
- [ ] Verificar que el workflow se ejecuta sin errores
- [ ] Revisar logs de CloudTrail (opcional)

## 🔗 Referencias

- [GitHub Actions - OIDC Subject Claims](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token)
- [AWS - IAM Trust Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)

---

## 🎯 Resumen Rápido

**Problema**: Trust policy muy restrictiva
**Solución**: Cambiar a `repo:bcocbo/*:*`
**Comando**:
```bash
# Usar el archivo incluido
aws iam update-assume-role-policy \
  --role-name GitHubActionsRole \
  --policy-document file://aws-oidc-trust-policy.json
```

**Verificar**:
```bash
aws iam get-role --role-name GitHubActionsRole
```

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Solución verificada
