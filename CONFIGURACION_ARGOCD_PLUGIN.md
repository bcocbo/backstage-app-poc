# Configuración del Plugin de ArgoCD en Backstage

## ✅ Plugin Restaurado y Configurado

### 1. Componentes del Plugin

**Frontend (EntityPage.tsx):**
- ✅ Import de `EntityArgoCDOverviewCard`, `EntityArgoCDHistoryCard`, `isArgocdAvailable`
- ✅ Card de ArgoCD en el overview de la entidad
- ✅ Pestaña dedicada de ArgoCD con overview y historial

**Catalog Info (catalog-info.yaml):**
```yaml
metadata:
  annotations:
    argocd/app-name: ${{ values.name }}
    argocd/app-namespace: argocd
```

**App Config (app-config.yaml):**
```yaml
argocd:
  username: ${ARGOCD_USERNAME}
  password: ${ARGOCD_PASSWORD}
  waitCycles: 25
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argoInstance1
          url: ${ARGOCD_URL}
```

---

## 🔧 Configuración Requerida

### Variables de Entorno (.env)

Actualiza tu archivo `.env` con las credenciales correctas de ArgoCD:

```bash
# ArgoCD Configuration
ARGOCD_URL=https://argocd.pocarqnube.com  # O tu URL de ArgoCD
ARGOCD_USERNAME=admin
ARGOCD_PASSWORD=tu-password-real

# O usa token (recomendado para producción)
# ARGOCD_AUTH_TOKEN=tu-token-de-argocd
```

### Obtener Token de ArgoCD (Recomendado)

```bash
# Login a ArgoCD
argocd login argocd.pocarqnube.com

# Generar token
argocd account generate-token --account admin

# Agregar al .env
ARGOCD_AUTH_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Luego actualiza `app-config.yaml` para usar token:

```yaml
argocd:
  token: ${ARGOCD_AUTH_TOKEN}  # En lugar de username/password
  waitCycles: 25
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argoInstance1
          url: ${ARGOCD_URL}
```

---

## 📋 Cómo Funciona

### 1. Creación de App en Backstage

Cuando creas una app con el scaffolder, se genera un `catalog-info.yaml` con:

```yaml
metadata:
  annotations:
    argocd/app-name: myapp-010
    argocd/app-namespace: argocd
```

### 2. Plugin Busca la App en ArgoCD

El plugin usa estas anotaciones para:
1. Conectarse a ArgoCD usando las credenciales del `.env`
2. Buscar la aplicación `myapp-010` en el namespace `argocd`
3. Mostrar el estado, sync status, health, etc.

### 3. Visualización en Backstage

**En el Overview:**
- Card con estado de la aplicación
- Sync status (Synced/OutOfSync)
- Health status (Healthy/Degraded/Missing)
- Link directo a ArgoCD UI

**En la pestaña ArgoCD:**
- Overview completo de la aplicación
- Historial de sincronizaciones
- Detalles de recursos desplegados

---

## 🚨 Troubleshooting

### Error: "Cannot get argo location(s) for service"

**Causa:** La aplicación no tiene las anotaciones de ArgoCD o no existe en ArgoCD.

**Solución:**
1. Verifica que el `catalog-info.yaml` tenga las anotaciones
2. Verifica que la aplicación exista en ArgoCD:
   ```bash
   argocd app get myapp-010
   ```
3. Verifica que el nombre coincida exactamente

### Error: "Failed to fetch ArgoCD applications"

**Causa:** Credenciales incorrectas o ArgoCD no accesible.

**Solución:**
1. Verifica las credenciales en `.env`
2. Verifica que ArgoCD sea accesible:
   ```bash
   curl -k https://argocd.pocarqnube.com
   ```
3. Verifica los logs de Backstage:
   ```bash
   # En la consola donde corre Backstage
   # Busca errores relacionados con ArgoCD
   ```

### Error: "SSL certificate problem"

**Causa:** ArgoCD usa certificado self-signed.

**Solución:** Agrega `skipTLSVerify: true` en app-config.yaml:

```yaml
argocd:
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argoInstance1
          url: ${ARGOCD_URL}
          skipTLSVerify: true  # ← Agregar esto
```

---

## ✅ Verificación

### 1. Reinicia Backstage

```bash
# Detener procesos
lsof -ti:7007 | xargs kill -9
lsof -ti:3000 | xargs kill -9

# Iniciar
NODE_OPTIONS=--no-node-snapshot yarn start
```

### 2. Crea una App de Prueba

1. Ve a "Create" en Backstage
2. Selecciona "ArgoCD - Aplicación Hola Mundo"
3. Completa el formulario
4. Espera a que se cree

### 3. Verifica el Plugin

1. Ve al catálogo y busca tu app
2. Deberías ver el card de ArgoCD en el overview
3. Ve a la pestaña "ArgoCD"
4. Deberías ver el estado de la aplicación

---

## 🎯 Resultado Esperado

**Overview Card:**
```
┌─────────────────────────────────┐
│ ArgoCD Application              │
├─────────────────────────────────┤
│ Name: myapp-010                 │
│ Status: Synced ✓                │
│ Health: Healthy ✓               │
│ Sync: Auto                      │
│                                 │
│ [View in ArgoCD] →              │
└─────────────────────────────────┘
```

**ArgoCD Tab:**
- Overview con detalles completos
- Historial de sincronizaciones
- Lista de recursos (Deployment, Service, etc.)
- Links a recursos en Kubernetes

---

## 📚 Referencias

- [Roadie ArgoCD Plugin](https://roadie.io/backstage/plugins/argo-cd/)
- [ArgoCD API Docs](https://argo-cd.readthedocs.io/en/stable/developer-guide/api-docs/)
- [Backstage Catalog Annotations](https://backstage.io/docs/features/software-catalog/well-known-annotations)
