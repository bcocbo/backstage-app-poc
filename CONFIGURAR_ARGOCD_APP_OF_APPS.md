# 🔄 Configurar ArgoCD App-of-Apps

## 📋 Objetivo

Configurar ArgoCD para que detecte automáticamente las nuevas aplicaciones creadas por Backstage en el repositorio GitOps.

## 🎯 Patrón App-of-Apps

El patrón "App-of-Apps" permite que ArgoCD monitoree un directorio y cree automáticamente aplicaciones basadas en los archivos YAML que encuentra.

## 🚀 Configuración

### Paso 1: Crear App-of-Apps para cada entorno

Crea estas aplicaciones en ArgoCD (una por entorno):

#### Dev Environment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: dev-apps
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/bcocbo/gitops-apps
    targetRevision: HEAD
    path: argocd/applications/dev
  
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

#### Staging Environment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: staging-apps
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/bcocbo/gitops-apps
    targetRevision: HEAD
    path: argocd/applications/staging
  
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

#### Production Environment

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prod-apps
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/bcocbo/gitops-apps
    targetRevision: HEAD
    path: argocd/applications/prod
  
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  
  syncPolicy:
    automated:
      prune: false  # No auto-prune en producción
      selfHeal: false  # No auto-heal en producción
```

### Paso 2: Aplicar las App-of-Apps

#### Opción A: Usando ArgoCD CLI

```bash
# Dev
argocd app create dev-apps \
  --repo https://github.com/bcocbo/gitops-apps \
  --path argocd/applications/dev \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Staging
argocd app create staging-apps \
  --repo https://github.com/bcocbo/gitops-apps \
  --path argocd/applications/staging \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Production
argocd app create prod-apps \
  --repo https://github.com/bcocbo/gitops-apps \
  --path argocd/applications/prod \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd
```

#### Opción B: Usando kubectl

```bash
# Guardar los YAMLs en archivos
cat > dev-apps.yaml << 'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: dev-apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/bcocbo/gitops-apps
    targetRevision: HEAD
    path: argocd/applications/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Aplicar
kubectl apply -f dev-apps.yaml -n argocd
```

#### Opción C: Usando ArgoCD UI

1. Ve a ArgoCD UI
2. Click en **+ NEW APP**
3. Configura:
   - **Application Name**: `dev-apps`
   - **Project**: `default`
   - **Sync Policy**: `Automatic`
   - **Repository URL**: `https://github.com/bcocbo/gitops-apps`
   - **Path**: `argocd/applications/dev`
   - **Cluster**: `https://kubernetes.default.svc`
   - **Namespace**: `argocd`
4. Click **CREATE**

### Paso 3: Verificar

```bash
# Ver las App-of-Apps
argocd app list | grep apps

# Ver aplicaciones creadas automáticamente
argocd app list

# Ver detalles de una App-of-Apps
argocd app get dev-apps
```

## 🎯 Flujo Completo

```
1. Backstage crea app
   ↓
2. Commit en gitops-apps/argocd/applications/dev/my-app.yaml
   ↓
3. ArgoCD detecta cambio en dev-apps (App-of-Apps)
   ↓
4. ArgoCD crea aplicación "my-app" automáticamente
   ↓
5. ArgoCD sincroniza y despliega my-app
```

## 📊 Estructura del Repo GitOps

```
gitops-apps/
├── argocd/
│   ├── applications/
│   │   ├── dev/
│   │   │   ├── app1.yaml      ← ArgoCD detecta estos
│   │   │   └── app2.yaml
│   │   ├── staging/
│   │   │   └── app1.yaml
│   │   └── prod/
│   │       └── app1.yaml
│   └── projects/
│       ├── dev-project.yaml
│       ├── staging-project.yaml
│       └── prod-project.yaml
└── values/
    ├── dev/
    │   ├── app1/
    │   │   └── values.yaml
    │   └── app2/
    │       └── values.yaml
    ├── staging/
    └── prod/
```

## ✅ Verificación

### 1. Verificar App-of-Apps

```bash
# Listar App-of-Apps
argocd app list | grep -E "dev-apps|staging-apps|prod-apps"

# Deberías ver:
# dev-apps      argocd  Synced  Healthy
# staging-apps  argocd  Synced  Healthy
# prod-apps     argocd  Synced  Healthy
```

### 2. Crear App de Prueba en Backstage

1. Ve a Backstage → Create
2. Crea una app de prueba
3. Espera 1-2 minutos

### 3. Verificar que ArgoCD la Detectó

```bash
# Ver todas las apps
argocd app list

# Deberías ver tu nueva app
# test-app  dev  Synced  Healthy
```

## 🐛 Troubleshooting

### App-of-Apps no sincroniza

```bash
# Forzar sync
argocd app sync dev-apps

# Ver logs
argocd app logs dev-apps
```

### Aplicación no aparece

```bash
# Verificar que el archivo existe en GitOps
curl https://raw.githubusercontent.com/bcocbo/gitops-apps/main/argocd/applications/dev/my-app.yaml

# Verificar permisos de ArgoCD
argocd proj get default
```

### Error de permisos

```bash
# Verificar que el proyecto permite el namespace
argocd proj get dev

# Agregar namespace si es necesario
argocd proj add-destination dev https://kubernetes.default.svc dev
```

## 💡 Mejores Prácticas

### 1. Separar por Entorno

- ✅ Una App-of-Apps por entorno
- ✅ Políticas diferentes por entorno
- ✅ Prod sin auto-prune/self-heal

### 2. Usar Projects de ArgoCD

```bash
# Crear proyecto por entorno
argocd proj create dev \
  --description "Development environment" \
  --dest https://kubernetes.default.svc,dev \
  --src https://github.com/bcocbo/*
```

### 3. Configurar Notificaciones

```yaml
# En argocd-notifications-cm ConfigMap
triggers:
  - name: on-deployed
    enabled: true
  - name: on-health-degraded
    enabled: true
```

## 🎉 Resultado

Una vez configurado:

1. ✅ Backstage crea app → Archivo en GitOps
2. ✅ ArgoCD detecta automáticamente
3. ✅ ArgoCD crea y sincroniza la app
4. ✅ App desplegada en Kubernetes
5. ✅ Sin intervención manual

**¡GitOps completo y automatizado!** 🚀

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Guía completa para App-of-Apps
