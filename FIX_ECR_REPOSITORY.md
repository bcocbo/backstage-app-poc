# 🔧 Fix: ECR Repository Does Not Exist

## ❌ Error

```
The repository with name 'test-app04' does not exist in the registry with id '226633502530'
```

## ✅ Solución Aplicada

He actualizado el workflow para **crear automáticamente** el repositorio de ECR si no existe.

### Cambio en el Workflow

Agregué este step después del login a ECR:

```yaml
- name: Create ECR repository if it doesn't exist
  run: |
    aws ecr describe-repositories --repository-names ${{ env.ECR_REPOSITORY }} || \
    aws ecr create-repository \
      --repository-name ${{ env.ECR_REPOSITORY }} \
      --image-scanning-configuration scanOnPush=true \
      --encryption-configuration encryptionType=AES256 \
      --tags Key=ManagedBy,Value=Backstage
```

**Cómo funciona**:
1. Intenta describir el repositorio
2. Si falla (no existe), lo crea automáticamente
3. Configura scan de imágenes y encriptación

## 🔐 Permisos Necesarios

El rol de IAM necesita permisos adicionales para crear repositorios:

### Verificar Permisos Actuales

```bash
# Ver políticas del rol
aws iam list-attached-role-policies --role-name GitHubActionsRole

# Ver política inline (si existe)
aws iam get-role-policy --role-name GitHubActionsRole --policy-name ECRPolicy
```

### Agregar Permisos de ECR

#### Opción 1: Usar Política Administrada (Más Fácil)

```bash
# Adjuntar política de ECR Power User
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
```

Esta política incluye:
- ✅ `ecr:CreateRepository`
- ✅ `ecr:DescribeRepositories`
- ✅ `ecr:PutImage`
- ✅ `ecr:BatchCheckLayerAvailability`
- ✅ Y más...

#### Opción 2: Política Personalizada (Más Restrictiva)

Si prefieres permisos mínimos:

```bash
# Crear política personalizada
cat > ecr-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository",
        "ecr:DescribeRepositories",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImageTagMutability",
        "ecr:PutImageScanningConfiguration",
        "ecr:TagResource"
      ],
      "Resource": "arn:aws:ecr:us-east-1:226633502530:repository/*"
    }
  ]
}
EOF

# Crear la política
aws iam create-policy \
  --policy-name GitHubActionsECRPolicy \
  --policy-document file://ecr-policy.json

# Adjuntar al rol
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::226633502530:policy/GitHubActionsECRPolicy
```

## 🚀 Para Apps Existentes

### Si tu app ya fue creada sin este fix:

#### Opción A: Actualizar el Workflow Manualmente

```bash
# 1. Clona tu repo
git clone https://github.com/bcocbo/test-app04.git
cd test-app04

# 2. Edita .github/workflows/ci.yaml
# Agrega el step "Create ECR repository" después de "Login to Amazon ECR"

# 3. Push
git add .github/workflows/ci.yaml
git commit -m "feat: Auto-create ECR repository if not exists"
git push origin main
```

#### Opción B: Crear el Repositorio Manualmente

```bash
# Crear repositorio para test-app04
aws ecr create-repository \
  --repository-name test-app04 \
  --region us-east-1 \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256 \
  --tags Key=ManagedBy,Value=Backstage Key=Application,Value=test-app04

# Verificar
aws ecr describe-repositories --repository-names test-app04
```

Luego vuelve a ejecutar el workflow:
```bash
# Trigger workflow manualmente
gh workflow run ci.yaml --repo bcocbo/test-app04
```

## 🎯 Para Nuevas Apps

Las nuevas apps que crees ya incluirán el step de creación automática de repositorio.

## 🔍 Verificar que Funciona

```bash
# Ver workflows
gh run list --repo bcocbo/test-app04

# Ver logs del último run
gh run view --repo bcocbo/test-app04 --log

# Buscar el step de creación de ECR
gh run view --repo bcocbo/test-app04 --log | grep -A 5 "Create ECR"
```

Deberías ver:
```
Create ECR repository if it doesn't exist
✓ Repository already exists
OR
✓ Repository created successfully
```

## 📊 Beneficios

- ✅ No necesitas crear repositorios manualmente
- ✅ Workflow más robusto
- ✅ Configuración consistente (scan, encryption)
- ✅ Tags automáticos para organización
- ✅ Menos errores de configuración

## 🐛 Troubleshooting

### Error: "AccessDeniedException: User is not authorized to perform: ecr:CreateRepository"

**Causa**: El rol no tiene permisos

**Solución**: Aplica Opción 1 o 2 de permisos arriba

### Error: "RepositoryAlreadyExistsException"

**Causa**: El repositorio ya existe (esto es normal)

**Solución**: El workflow maneja esto automáticamente con `||`

### Verificar Permisos del Rol

```bash
# Ver todas las políticas del rol
aws iam list-attached-role-policies --role-name GitHubActionsRole

# Debería mostrar algo como:
# - AmazonEC2ContainerRegistryPowerUser
# O tu política personalizada
```

## 💡 Mejores Prácticas

### 1. Lifecycle Policy

Después de crear el repositorio, considera agregar una política de ciclo de vida:

```bash
cat > lifecycle-policy.json << 'EOF'
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF

aws ecr put-lifecycle-policy \
  --repository-name test-app04 \
  --lifecycle-policy-text file://lifecycle-policy.json
```

### 2. Repository Policy

Para permitir que otros servicios accedan:

```bash
cat > repository-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
    }
  ]
}
EOF

aws ecr set-repository-policy \
  --repository-name test-app04 \
  --policy-text file://repository-policy.json
```

## 📋 Checklist

- [ ] Workflow actualizado con step de creación de ECR
- [ ] Rol de IAM tiene permisos de ECR
- [ ] Permisos verificados con `aws iam list-attached-role-policies`
- [ ] Workflow ejecutado exitosamente
- [ ] Imagen subida a ECR
- [ ] Repositorio visible en AWS Console

## 🎉 Resultado

Ahora cuando crees una nueva app:
1. ✅ El workflow se ejecuta
2. ✅ Crea el repositorio de ECR automáticamente
3. ✅ Sube la imagen
4. ✅ Actualiza GitOps
5. ✅ ArgoCD despliega

**¡Sin intervención manual!** 🚀

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Workflow actualizado para crear repositorios automáticamente
