# GitOps Setup - Repositorios Creados

## ✅ Repositorios Creados

### 1. Chart Transversal de Helm
- **Repositorio**: https://github.com/bcocbo/eks_baseline_chart_Helm
- **Descripción**: Chart base reutilizable para todos los despliegues en EKS
- **Versión**: 1.0.0
- **Contenido**:
  - Deployment con security best practices
  - Service, Ingress, HPA
  - ConfigMap y Secret support
  - ServiceAccount
  - Documentación completa

### 2. Repositorio GitOps
- **Repositorio**: https://github.com/bcocbo/gitops-apps
- **Descripción**: Configuración centralizada de aplicaciones con ArgoCD
- **Estructura**:
  ```
  gitops-apps/
  ├── charts/              # Referencias a charts
  ├── values/              # Values por entorno (dev/staging/prod)
  ├── argocd/
  │   ├── app-of-apps.yaml
  │   ├── projects/        # Proyectos de ArgoCD
  │   └── applications/    # Definiciones de apps
  └── README.md
  ```

## 🔧 Configuración de Backstage

### Token de GitHub
El token de GitHub está configurado en:
- **Archivo**: `.env`
- **Variable**: `GITHUB_TOKEN`
- **Usuario**: bcocbo

### app-config.yaml
Se agregó la configuración del scaffolder:
```yaml
scaffolder:
  defaultAuthor:
    name: Backstage
    email: backstage@example.com
  defaultCommitMessage: 'Initial commit from Backstage'
```

## 📝 Uso en Templates

### Referencia al Chart Transversal

En las ArgoCD Applications, usa:
```yaml
source:
  repoURL: https://github.com/bcocbo/eks_baseline_chart_Helm
  targetRevision: HEAD
  path: .
  helm:
    valueFiles:
      - ../../values/dev/my-app/values.yaml
```

### Repositorio GitOps en Templates

En el template de Backstage, configura:
```yaml
parameters:
  - title: Repositorio GitOps
    properties:
      gitopsRepoUrl:
        title: URL del Repositorio GitOps
        type: string
        default: https://github.com/bcocbo/gitops-apps
      gitopsPath:
        title: Path en el Repositorio GitOps
        type: string
        default: values
      gitopsBranch:
        title: Branch del Repositorio GitOps
        type: string
        default: main
```

## 🚀 Próximos Pasos

1. **Configurar ArgoCD**:
   - Instalar ArgoCD en el cluster
   - Aplicar los proyectos: `kubectl apply -f gitops-apps/argocd/projects/`
   - Aplicar app-of-apps: `kubectl apply -f gitops-apps/argocd/app-of-apps.yaml`

2. **Actualizar Template de Backstage**:
   - Modificar `examples/argocd-template/template.yaml`
   - Actualizar referencias a los nuevos repositorios
   - Agregar parámetros de entorno (dev/staging/prod)

3. **Crear CI/CD Workflow**:
   - Agregar `.github/workflows/ci.yaml` al template
   - Configurar build y push de imagen Docker
   - Implementar script de actualización de GitOps

4. **Configurar ArgoCD Plugin en Backstage**:
   - Instalar backend plugin de ArgoCD
   - Configurar credenciales de ArgoCD en app-config.yaml
   - Agregar ArgoCD card al EntityPage

## 🔐 Seguridad

- ✅ Token de GitHub configurado en `.env` (no commiteado)
- ✅ Repositorios públicos sin secretos
- ✅ Secretos de aplicaciones manejados por Kubernetes Secrets
- ⚠️ Recuerda configurar branch protection en GitHub para `main`

## 📚 Documentación

- **Chart Helm**: Ver `charts/eks_baseline_chart_Helm/README.md`
- **GitOps**: Ver `gitops-apps/README.md`
- **Diseño**: Ver `.kiro/specs/backstage-argocd-gitops-flow/design.md`
- **Tareas**: Ver `.kiro/specs/backstage-argocd-gitops-flow/tasks.md`

## 🆘 Troubleshooting

### Error: "Bad credentials" al crear repos
- Verificar que el token de GitHub esté correcto en `.env`
- Verificar que el token tenga permisos de `repo`

### ArgoCD no detecta cambios
- Verificar que la URL del repositorio sea correcta
- Verificar que ArgoCD tenga acceso al repositorio
- Revisar los logs de ArgoCD: `kubectl logs -n argocd deployment/argocd-repo-server`

### Template falla al crear PR en GitOps
- Verificar que el token tenga permisos de `repo` y `workflow`
- Verificar que la URL del repositorio GitOps sea correcta
- Revisar logs del scaffolder en Backstage
