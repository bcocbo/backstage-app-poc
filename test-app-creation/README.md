# demo-app

Aplicación de prueba para GitOps creada desde Backstage.

## Descripción

Esta aplicación demuestra el flujo completo de GitOps con ArgoCD:
- Código de aplicación en este repositorio
- Configuración de despliegue en [gitops-apps](https://github.com/bcocbo/gitops-apps)
- Chart transversal de Helm en [eks_baseline_chart_Helm](https://github.com/bcocbo/eks_baseline_chart_Helm)

## Despliegue

La aplicación se despliega automáticamente usando ArgoCD cuando:
1. Se hace merge del PR en el repositorio GitOps
2. ArgoCD detecta los cambios (cada 3 minutos)
3. ArgoCD sincroniza el estado deseado con Kubernetes

## Configuración

- **Entorno**: dev
- **Namespace**: dev
- **Imagen**: nginxdemos/hello:latest
- **Réplicas**: 2

## Enlaces

- [ArgoCD Application](https://argocd.example.com/applications/demo-app)
- [GitOps Config](https://github.com/bcocbo/gitops-apps/tree/main/values/dev/demo-app)
- [Helm Chart](https://github.com/bcocbo/eks_baseline_chart_Helm)

## Desarrollo

```bash
# Construir imagen Docker
docker build -t demo-app:latest .

# Ejecutar localmente
docker run -p 8080:80 demo-app:latest
```

## CI/CD

El pipeline de CI/CD se ejecuta automáticamente en cada push:
1. Lint y tests
2. Build de imagen Docker
3. Push a registry
4. Actualización de imageTag en GitOps

Ver `.github/workflows/ci.yaml` para más detalles.
