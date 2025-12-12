# Plantilla ArgoCD - Hola Mundo

Esta plantilla de Backstage te permite desplegar rápidamente una aplicación "Hola Mundo" usando ArgoCD y GitOps.

## ¿Qué hace esta plantilla?

1. **Crea un repositorio** para tu aplicación con:
   - Dockerfile
   - Documentación
   - Configuración de catálogo de Backstage

2. **Actualiza tu repositorio GitOps** con:
   - Manifiestos de Kubernetes (Deployment + Service)
   - Values de Helm
   - Definición de aplicación de ArgoCD

3. **Crea un Pull Request** en el repositorio GitOps para revisión

4. **Registra la aplicación** en el catálogo de Backstage

## Requisitos Previos

### 1. Repositorio GitOps

Necesitas tener un repositorio GitOps donde ArgoCD lee las configuraciones. Estructura recomendada:

```
gitops-repo/
├── apps/
│   ├── app1/
│   │   ├── deployment.yaml
│   │   ├── values.yaml
│   │   └── argocd-application.yaml
│   └── app2/
│       └── ...
└── README.md
```

### 2. Token de GitHub

Configura un token de GitHub con permisos para:
- Crear repositorios
- Crear Pull Requests
- Leer/escribir en el repositorio GitOps

Agrega el token en tu archivo `.env`:
```bash
GITHUB_TOKEN=ghp_tu_token_aqui
```

### 3. ArgoCD Instalado

Asegúrate de tener ArgoCD instalado en tu cluster:

```bash
# Instalar ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Acceder a ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Cómo Usar la Plantilla

### Paso 1: Acceder a Backstage

1. Inicia Backstage:
   ```bash
   yarn dev
   ```

2. Ve a **Create** en el menú lateral

3. Selecciona **ArgoCD - Aplicación Hola Mundo**

### Paso 2: Completar el Formulario

#### Información de la Aplicación
- **Nombre**: Nombre único (ej. `hola-mundo-dev`)
- **Namespace**: Namespace de Kubernetes (ej. `default`)
- **Descripción**: Descripción de tu aplicación

#### Configuración de la Imagen
- **Imagen Docker**: `nginxdemos/hello` (o tu imagen preferida)
- **Tag**: `latest`
- **Réplicas**: Número de pods (ej. `2`)

#### Repositorio de la Aplicación
- Selecciona la organización y nombre del nuevo repositorio

#### Repositorio GitOps
- **URL del Repositorio GitOps**: URL completa (ej. `https://github.com/tu-org/gitops-repo`)
- **Path**: Ruta donde se guardarán los manifiestos (ej. `apps`)
- **Branch**: Branch a modificar (ej. `main`)

### Paso 3: Crear la Aplicación

1. Haz clic en **Create**
2. Backstage ejecutará todos los pasos automáticamente
3. Verás los enlaces al repositorio y al Pull Request

### Paso 4: Aprobar y Desplegar

1. **Revisa el Pull Request** en el repositorio GitOps
2. **Aprueba y merge** el PR
3. **ArgoCD detectará los cambios** automáticamente y desplegará la aplicación

### Paso 5: Verificar el Despliegue

```bash
# Ver la aplicación en ArgoCD
argocd app get hola-mundo-dev

# Ver los pods
kubectl get pods -n default -l app=hola-mundo-dev

# Acceder a la aplicación
kubectl port-forward -n default svc/hola-mundo-dev 8080:80

# Visita: http://localhost:8080
```

## Personalización

### Cambiar la Imagen

Edita el archivo `values.yaml` o `deployment.yaml` en el repositorio GitOps:

```yaml
image:
  repository: tu-imagen
  tag: v1.0.0
```

### Agregar Ingress

Edita `values.yaml` en el repositorio GitOps:

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: hola-mundo.tu-dominio.com
      paths:
        - path: /
          pathType: Prefix
```

### Escalar la Aplicación

```bash
# Edita el número de réplicas en values.yaml
# O usa kubectl directamente:
kubectl scale deployment hola-mundo-dev -n default --replicas=5
```

## Troubleshooting

### La aplicación no aparece en ArgoCD

1. Verifica que el archivo `argocd-application.yaml` esté en el repositorio GitOps
2. Aplica manualmente:
   ```bash
   kubectl apply -f argocd-application.yaml
   ```

### Error "Failed to fetch"

1. Verifica que el backend de Backstage esté corriendo
2. Revisa los logs del backend
3. Verifica la configuración de CORS en `app-config.yaml`

### Pull Request no se crea

1. Verifica que el token de GitHub tenga los permisos correctos
2. Verifica que la URL del repositorio GitOps sea correcta
3. Revisa los logs del scaffolder en Backstage

## Estructura de Archivos Generados

### Repositorio de la Aplicación
```
hola-mundo-dev/
├── README.md
├── Dockerfile
├── catalog-info.yaml
└── .gitignore
```

### Repositorio GitOps
```
gitops-repo/apps/hola-mundo-dev/
├── deployment.yaml          # Deployment + Service
├── values.yaml              # Valores de configuración
├── argocd-application.yaml  # Definición de ArgoCD
└── README.md
```

## Próximos Pasos

1. **Configura CI/CD**: Agrega GitHub Actions para construir y publicar imágenes Docker
2. **Agrega Monitoring**: Integra Prometheus y Grafana
3. **Configura Alertas**: Usa ArgoCD Notifications
4. **Implementa Canary Deployments**: Usa Argo Rollouts

## Referencias

- [Documentación de ArgoCD](https://argo-cd.readthedocs.io/)
- [Backstage Software Templates](https://backstage.io/docs/features/software-templates/)
- [GitOps con ArgoCD](https://www.gitops.tech/)

---
Creado con ❤️ usando Backstage
