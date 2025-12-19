# Flujo Completo: Backstage → GitOps → ArgoCD

## ✅ Verificación Completa del Flujo

### 1. Creación de App en Backstage

**Usuario completa el formulario:**
- Nombre: `myapp-010`
- Entorno: `dev`
- Tipo: `custom` (Python)
- Réplicas: `2`

**Backstage ejecuta:**

1. **Crea repo de la app** (`bcocbo/myapp-010`):
   - `Dockerfile` (Python con Flask)
   - `app.py` (Hello World con /health endpoint)
   - `requirements.txt` (Flask)
   - `healthcheck.py`
   - `.github/workflows/ci.yaml` (CI/CD)
   - `catalog-info.yaml`

2. **Crea PR en GitOps** (`bcocbo/gitops-apps`):
   - `values/dev/myapp-010/values.yaml` (con estructura `microservice.*`)
   - `argocd/applications/dev/myapp-010.yaml` (Application de ArgoCD)

---

### 2. Aprobación del PR en GitOps

**DevOps aprueba el PR:**
- Los archivos se mergean a `main` en `gitops-apps`
- ArgoCD App-of-Apps detecta el nuevo archivo en `argocd/applications/dev/`
- ArgoCD crea automáticamente la Application `myapp-010`

**Estado en ArgoCD:**
- Application: `myapp-010`
- Status: `OutOfSync` (imagen aún no existe)
- Health: `Missing` (deployment no puede crear pods)

---

### 3. Primer Build de la App

**Developer hace commit en el repo de la app:**
```bash
git commit --allow-empty -m "trigger first build"
git push origin main
```

**Workflow CI/CD se ejecuta:**

1. **Build & Push:**
   - Construye imagen Docker con Python + Flask
   - Crea repo ECR si no existe: `test-app010`
   - Push imagen: `226633502530.dkr.ecr.us-east-1.amazonaws.com/myapp-010:main-abc1234-1`

2. **Update GitOps:**
   - Clona `gitops-apps`
   - Crea branch: `update-myapp-010-abc1234`
   - Actualiza `values/dev/myapp-010/values.yaml`:
     ```yaml
     microservice:
       image: "226633502530.dkr.ecr.us-east-1.amazonaws.com/myapp-010:main-abc1234-1"
     ```
   - Crea PR en GitOps

3. **DevOps aprueba PR:**
   - Cambios se mergean a `main`
   - ArgoCD detecta cambio en values.yaml
   - ArgoCD sincroniza automáticamente

---

### 4. Despliegue en Kubernetes

**ArgoCD renderiza el chart:**

```yaml
# ArgoCD usa múltiples sources:
# Source 1: Chart de Helm (eks_baseline_chart_Helm)
# Source 2: Values de GitOps (gitops-apps/values/dev/myapp-010/values.yaml)
```

**Helm renderiza con los values:**
```yaml
microservice:
  name: "myapp-010"
  namespace: "dev"
  image: "226633502530.dkr.ecr.us-east-1.amazonaws.com/myapp-010:main-abc1234-1"
  port: 8000
  replicas: 2
  securityContext:
    runAsUser: 1001
  probes:
    liveness:
      httpGet:
        path: /health
        port: 8000
    readiness:
      httpGet:
        path: /health
        port: 8000
```

**Kubernetes crea:**
- Deployment: `myapp-010-deployment` (2 pods)
- Service: `myapp-010-service` (ClusterIP, port 80 → 8000)
- ConfigMap: `myapp-010-configmap`

**Pods inician:**
- Pull imagen desde ECR
- Ejecutan Flask app en puerto 8000
- Health checks pasan
- Status: `Running` y `Ready`

---

### 5. Actualizaciones Posteriores

**Developer hace cambios en el código:**
```bash
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main
```

**Workflow CI/CD:**
1. Build nueva imagen: `main-xyz5678-2`
2. Crea PR en GitOps con nuevo tag
3. DevOps aprueba
4. ArgoCD sincroniza automáticamente
5. Rolling update en Kubernetes (maxUnavailable: 0)

---

## 🔍 Puntos de Verificación

### ✅ Backstage Template
- [x] Crea repo con código Python + Flask
- [x] Dockerfile correcto (usuario 1001, PATH correcto)
- [x] Workflow CI/CD configurado
- [x] Values.yaml con estructura `microservice.*`
- [x] Application de ArgoCD con múltiples sources

### ✅ Workflow CI/CD
- [x] Crea repo ECR automáticamente
- [x] Build y push de imagen
- [x] Actualiza `microservice.image` en values.yaml (no `.image.repository`)
- [x] Crea PR en GitOps
- [x] Ignora cambios en README, docs, .gitignore

### ✅ Chart de Helm
- [x] Usa estructura `microservice.*`
- [x] Security context para non-root (usuario 1001)
- [x] Health checks configurables
- [x] Service con targetPort correcto
- [x] ConfigMap para variables de entorno

### ✅ ArgoCD
- [x] App-of-Apps monitorea `argocd/applications/dev/`
- [x] Application usa múltiples sources
- [x] ValueFiles apunta a `$values/values/dev/myapp-010/values.yaml`
- [x] Sync automático habilitado
- [x] Proyecto `dev` con permisos correctos

---

## 🚨 Problemas Corregidos

1. **❌ Workflow actualizaba `.image.repository`**
   - ✅ Ahora actualiza `.microservice.image` (imagen completa)

2. **❌ Chart usaba estructura plana**
   - ✅ Ahora usa `microservice.*` del chart real

3. **❌ Health checks en puerto incorrecto**
   - ✅ Configurados para puerto 8000 y path `/health`

4. **❌ Security context incompatible**
   - ✅ Usuario 1001 coincide con Dockerfile

5. **❌ readOnlyRootFilesystem bloqueaba Python**
   - ✅ Chart permite escritura de temporales

---

## 📋 Checklist de Despliegue

### Antes de crear una app:

- [ ] ArgoCD App-of-Apps configurado
- [ ] Proyecto `dev` en ArgoCD con permisos
- [ ] Security Groups permiten tráfico ALB → Pods
- [ ] OIDC configurado para GitHub Actions
- [ ] Secrets en GitHub: `AWS_ROLE_ARN`, `GITOPS_TOKEN`
- [ ] Chart de Helm mergeado en `eks_baseline_chart_Helm`

### Al crear una app:

- [ ] Aprobar PR en GitOps (setup inicial)
- [ ] Verificar que ArgoCD cree la Application
- [ ] Hacer commit en repo de app para trigger build
- [ ] Aprobar PR de actualización de imagen
- [ ] Verificar pods en estado Running
- [ ] Verificar health checks pasando

### Troubleshooting:

```bash
# Ver Application en ArgoCD
argocd app get myapp-010

# Ver pods
kubectl get pods -n dev -l pod=myapp-010-pod

# Ver logs
kubectl logs -n dev -l pod=myapp-010-pod

# Describe pod
kubectl describe pod -n dev <pod-name>

# Ver events
kubectl get events -n dev --sort-by='.lastTimestamp'
```

---

## ✅ Flujo Verificado y Funcional

El flujo completo está configurado correctamente y listo para producción.
