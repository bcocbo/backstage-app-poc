# Prueba del Template de Backstage

## ✅ Estado Actual

### Repositorios Creados
1. **Chart Transversal**: https://github.com/bcocbo/eks_baseline_chart_Helm
2. **GitOps**: https://github.com/bcocbo/gitops-apps

### Configuración Completada
- ✅ Token de GitHub configurado en `.env`
- ✅ Scaffolder configurado en `app-config.yaml`
- ✅ Template actualizado con URLs correctas
- ✅ Selección de entorno (dev/staging/prod)
- ✅ Estructura GitOps correcta

### Template Actualizado
El template ahora:
- ✅ Permite seleccionar entorno (dev/staging/prod)
- ✅ Crea repositorio de aplicación en GitHub
- ✅ Genera values.yaml con configuración del chart transversal
- ✅ Genera ArgoCD Application manifest
- ✅ Crea PR en repositorio GitOps
- ✅ Registra componente en catálogo

## 🧪 Cómo Probar

### 1. Acceder a Backstage
```bash
# Si no está corriendo, iniciar:
yarn start

# O usar el script:
./start-backstage.sh
```

Accede a: http://localhost:3000

### 2. Navegar al Template
1. Click en "Create..." en el menú lateral
2. Busca "ArgoCD - Aplicación Hola Mundo"
3. Click en "Choose"

### 3. Llenar el Formulario

**Información de la Aplicación:**
- Nombre: `test-app` (solo minúsculas y guiones)
- Entorno: Selecciona `dev`
- Descripción: `Aplicación de prueba para GitOps`

**Configuración de la Imagen:**
- Imagen Docker: `nginxdemos/hello`
- Tag: `latest`
- Réplicas: `2`

**Repositorio:**
- Owner: `bcocbo`
- Repository: `test-app`

### 4. Ejecutar Template
Click en "Create" y espera a que complete todos los pasos.

### 5. Verificar Resultados

#### A. Repositorio de Aplicación Creado
Verifica en: https://github.com/bcocbo/test-app

Debe contener:
- ✅ `catalog-info.yaml` con anotaciones de ArgoCD
- ✅ `Dockerfile`
- ✅ `README.md`
- ✅ `.gitignore`

#### B. Pull Request en GitOps
Verifica en: https://github.com/bcocbo/gitops-apps/pulls

Debe contener:
- ✅ `values/dev/test-app/values.yaml` - Configuración de la app
- ✅ `argocd/applications/dev/test-app.yaml` - ArgoCD Application

#### C. Componente en Catálogo
1. Ve a "Catalog" en Backstage
2. Busca `test-app`
3. Verifica que aparece con:
   - Tags: argocd, kubernetes, gitops, dev
   - Links a ArgoCD y GitOps config
   - Owner correcto

## 📋 Checklist de Verificación

- [ ] Template aparece en la lista de templates
- [ ] Formulario se muestra correctamente
- [ ] Validación de campos funciona (nombre solo minúsculas)
- [ ] Selección de entorno funciona
- [ ] Repositorio de app se crea en GitHub
- [ ] Archivos correctos en el repo de app
- [ ] PR se crea en repositorio GitOps
- [ ] Estructura de archivos correcta en PR:
  - [ ] `values/dev/test-app/values.yaml`
  - [ ] `argocd/applications/dev/test-app.yaml`
- [ ] Componente aparece en catálogo
- [ ] Anotaciones de ArgoCD presentes
- [ ] Links funcionan correctamente

## 🐛 Troubleshooting

### Error: "Bad credentials"
- Verifica que el token en `.env` sea correcto
- Reinicia Backstage después de cambiar `.env`

### Error: "Repository already exists"
- Usa un nombre diferente para la app
- O elimina el repo existente en GitHub

### Template no aparece
- Verifica que el template esté en `app-config.yaml` bajo `catalog.locations`
- Reinicia Backstage

### PR no se crea
- Verifica que el token tenga permisos de `repo`
- Verifica que la URL del repo GitOps sea correcta
- Revisa logs del backend: `yarn workspace backend start`

## 📊 Tareas Completadas

De acuerdo al plan de implementación:

### ✅ Completadas
- [x] 2. Create transversal Helm chart
  - [x] 2.1 Set up Helm chart directory structure
  - [x] 2.2 Implement Helm templates
  - [x] 2.3 Add chart versioning and CHANGELOG

- [x] 3. Enhance Software Template (parcial)
  - [x] 3.1 Update template parameters (environment selection)
  - [x] 3.2 Implement template form validation

- [x] 6. Update template to generate complete repository structure (parcial)
  - [x] 6.2 Enhance catalog-info.yaml template

- [x] 7. Update GitOps values generation (parcial)
  - [x] 7.1 Update values.yaml template
  - [x] 7.2 Update ArgoCD Application manifest template
  - [x] 7.3 Implement environment-specific directory structure

- [x] 8. Enhance template actions for GitOps workflow (parcial)
  - [x] 8.1 Configure GitOps PR creation
  - [x] 8.2 Implement catalog registration

### ⏳ Pendientes
- [ ] 1. Configure ArgoCD integration in Backstage
- [ ] 4. Create CI/CD workflow template
- [ ] 5. Implement GitOps update automation
- [ ] 6.1 Add CI/CD workflow to template content
- [ ] 9. Create template output summary page
- [ ] 10. Set up testing infrastructure
- [ ] 11. Documentation and examples

## 🎯 Próximos Pasos

1. **Probar el template** siguiendo las instrucciones arriba
2. **Aprobar el PR** en gitops-apps para completar el flujo
3. **Agregar CI/CD workflow** para automatizar builds
4. **Configurar ArgoCD** para despliegue automático
5. **Agregar ArgoCD plugin** para visualización en Backstage
