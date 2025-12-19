# Plan de Pruebas - Workflow Optimizado

## Estado Actual

✅ **Cambios Implementados**:
1. Template actualizado para hacer commit directo en GitOps (sin PR inicial)
2. Workflow de CI/CD optimizado para evitar builds circulares
3. Documentación actualizada

⚠️ **Backstage está corriendo** - Necesita reinicio para cargar cambios del template

## Pasos para Probar

### 1. Reiniciar Backstage

```bash
./restart-backstage.sh
```

Esperar a que Backstage esté listo (aprox. 30-60 segundos).

### 2. Crear Nueva Aplicación de Prueba

1. Ir a Backstage UI: http://localhost:3000
2. Navegar a "Create" → "Choose a template"
3. Seleccionar "ArgoCD - Aplicación Hola Mundo"
4. Llenar el formulario:
   - **Nombre**: `test-workflow-opt` (o similar)
   - **Entorno**: `dev`
   - **Tipo**: `Aplicación Python`
   - **Réplicas**: `2`
   - **Repositorio**: Seleccionar owner `bcocbo`

5. Hacer clic en "Create"

### 3. Verificar Setup Inicial Automático

**Expectativa**: El setup debe completarse sin crear PR en GitOps.

**Verificar**:

a) En el output de Backstage:
   - ✅ Debe mostrar "Aplicación configurada automáticamente en GitOps"
   - ✅ Link al repositorio de la app
   - ✅ Link al repositorio GitOps
   - ❌ NO debe mostrar "Pull Request GitOps"

b) En GitHub - Repo GitOps (https://github.com/bcocbo/gitops-apps):
   ```bash
   # Verificar que se crearon los archivos directamente en main
   # Sin PR pendiente
   ```
   - ✅ Debe existir: `values/dev/test-workflow-opt/values.yaml`
   - ✅ Debe existir: `argocd/applications/dev/test-workflow-opt.yaml`
   - ✅ Commit directo en `main` (no PR)

c) En GitHub - Repo de la App:
   - ✅ Repositorio creado: `bcocbo/test-workflow-opt`
   - ✅ Archivos Python presentes: `app.py`, `requirements.txt`, `Dockerfile`
   - ✅ Workflow presente: `.github/workflows/ci.yaml`
   - ❌ Workflow NO debe haberse ejecutado aún (no hay push a main/develop todavía)

### 4. Verificar Primer Build

**Hacer un cambio en la app**:

```bash
# Clonar el repo de la app
git clone https://github.com/bcocbo/test-workflow-opt.git
cd test-workflow-opt

# Hacer un cambio simple
echo "# Test change" >> README.md
git add README.md
git commit -m "test: trigger first build"
git push origin main
```

**Verificar**:

a) GitHub Actions en repo de app:
   - ✅ Workflow debe ejecutarse
   - ✅ Debe crear repositorio ECR si no existe
   - ✅ Debe construir y subir imagen
   - ✅ Debe crear PR en GitOps con nueva imagen

b) GitHub - Repo GitOps:
   - ✅ Debe aparecer nuevo PR con título "Update test-workflow-opt image to..."
   - ✅ PR debe actualizar `values/dev/test-workflow-opt/values.yaml`
   - ✅ Debe cambiar `image.tag` a la nueva versión

### 5. Verificar que NO hay Builds Circulares

**Aprobar el PR en GitOps**:

```bash
# Ir a https://github.com/bcocbo/gitops-apps/pulls
# Aprobar y hacer merge del PR
```

**Verificar**:

a) Después del merge en GitOps:
   - ❌ Workflow en repo de app NO debe ejecutarse
   - ✅ Solo ArgoCD debe reaccionar al cambio

b) En ArgoCD:
   - ✅ Debe detectar el cambio en values.yaml
   - ✅ Debe desplegar la nueva imagen automáticamente

### 6. Verificar Paths Ignore

**Hacer cambio solo en documentación**:

```bash
cd test-workflow-opt
echo "# Documentation update" >> README.md
git add README.md
git commit -m "docs: update readme"
git push origin main
```

**Verificar**:
- ❌ Workflow NO debe ejecutarse (cambio ignorado por paths-ignore)

**Hacer cambio en código**:

```bash
# Modificar app.py
echo "# Code change" >> app.py
git add app.py
git commit -m "feat: update app"
git push origin main
```

**Verificar**:
- ✅ Workflow SÍ debe ejecutarse
- ✅ Debe crear nuevo PR en GitOps

## Resultados Esperados

### ✅ Éxito Total

- Setup inicial automático (sin PR manual)
- Primer build funciona correctamente
- Actualizaciones de imagen crean PRs en GitOps
- Cambios en GitOps NO disparan builds
- Cambios en docs NO disparan builds
- Cambios en código SÍ disparan builds

### ⚠️ Problemas Potenciales

#### Problema 1: Setup inicial crea PR en lugar de commit directo

**Causa**: `publish:github` podría no tener permisos o comportarse diferente.

**Solución**: Verificar permisos del token de GitHub o usar approach alternativo.

#### Problema 2: Workflow se ejecuta en cambios de GitOps

**Causa**: El workflow en el repo de app no tiene los paths-ignore correctos.

**Solución**: Verificar que el archivo `.github/workflows/ci.yaml` en el repo de la app tiene:
```yaml
on:
  push:
    branches:
      - main
      - develop
    paths-ignore:
      - 'README.md'
      - 'docs/**'
      - '.gitignore'
```

#### Problema 3: Primer build falla por falta de values.yaml

**Causa**: El workflow espera que values.yaml exista en GitOps.

**Solución**: Ya implementado - el workflow crea el archivo si no existe.

## Comandos Útiles

### Ver logs de Backstage
```bash
tail -f backstage.log
```

### Ver workflows en ejecución
```bash
# En el repo de la app
gh run list --limit 5
```

### Ver PRs en GitOps
```bash
# En el repo gitops-apps
gh pr list
```

### Limpiar apps de prueba
```bash
# Eliminar repo de app
gh repo delete bcocbo/test-workflow-opt --yes

# Eliminar archivos en GitOps (hacer PR o commit directo)
cd gitops-apps
git rm -r values/dev/test-workflow-opt
git rm argocd/applications/dev/test-workflow-opt.yaml
git commit -m "chore: remove test app"
git push
```

## Siguiente Paso

**Ejecutar**: `./restart-backstage.sh` y comenzar las pruebas.
