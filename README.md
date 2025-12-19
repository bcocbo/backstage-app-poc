# Backstage + ArgoCD + GitOps Platform

Plataforma de despliegue automatizado que integra Backstage, ArgoCD y GitOps para crear y desplegar aplicaciones en Kubernetes de forma automática.

## 🚀 Características

- **Portal de Desarrollador (Backstage)**: Interfaz web para crear aplicaciones
- **Templates de Software**: Plantillas para Python y Node.js
- **CI/CD Automatizado**: GitHub Actions integrado
- **GitOps**: Despliegues automáticos con ArgoCD
- **Helm Chart Transversal**: Templates estandarizados de Kubernetes

## 📋 Requisitos Previos

- Node.js 18+ y Yarn
- PostgreSQL 12+
- Cuenta de GitHub con token de acceso
- Cluster de Kubernetes con ArgoCD instalado
- AWS Account (para ECR)

## 🔧 Instalación Local

### 1. Clonar el Repositorio

```bash
git clone https://github.com/bcocbo/backstage-app-poc.git
cd backstage-app-poc
```

### 2. Instalar Dependencias

```bash
yarn install
```

### 3. Configurar PostgreSQL

```bash
# Crear base de datos
createdb backstage

# O usar el script incluido
./setup-postgres.sh
```

### 4. Configurar Variables de Entorno

Crear archivo `.env` en la raíz del proyecto:

```bash
# Node.js Configuration
NODE_OPTIONS=--no-node-snapshot

# PostgreSQL Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=tu_usuario
POSTGRES_PASSWORD=tu_password

# GitHub Token
GITHUB_TOKEN=tu_github_token

# ArgoCD Configuration (opcional para plugin)
ARGOCD_URL=https://argocd.tu-dominio.com
ARGOCD_USERNAME=admin
ARGOCD_PASSWORD=tu_password_argocd
```

### 5. Iniciar Backstage

```bash
yarn dev
```

Backstage estará disponible en: http://localhost:3000

## 🐳 Despliegue en Kubernetes

### Usando el Dockerfile incluido

```bash
# Build
docker build -t backstage:latest .

# Push a tu registry
docker tag backstage:latest tu-registry/backstage:latest
docker push tu-registry/backstage:latest
```

### Desplegar en EKS

```bash
# Port forward a Backstage
kubectl port-forward svc/backstage 3000:3000 -n backstage

# Port forward a ArgoCD (si es necesario)
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```

## 📝 Configuración de GitHub Secrets

Para que el CI/CD funcione, configura estos secrets en tus repositorios:

### En el repositorio de cada aplicación:

- `AWS_ROLE_ARN`: ARN del rol de AWS para OIDC
- `GITOPS_TOKEN`: Token de GitHub con permisos para el repo gitops-apps

### Script de configuración:

```bash
./setup-github-secrets.sh
```

## 🎯 Uso

### Crear una Nueva Aplicación

1. Accede a Backstage: http://localhost:3000
2. Ve a "Create" en el menú lateral
3. Selecciona "ArgoCD - Aplicación Hola Mundo"
4. Completa el formulario:
   - Nombre de la aplicación
   - Entorno (dev/staging/prod)
   - Tipo (Python custom o imagen preconstruida)
5. Haz clic en "Create"

### Flujo Automático

1. **Backstage** crea el repositorio en GitHub
2. **GitHub Actions** construye la imagen Docker
3. **ECR** almacena la imagen
4. **GitOps** actualiza la configuración (PR automático)
5. **ArgoCD** despliega automáticamente en Kubernetes

## 📁 Estructura del Proyecto

```
backstage-app-poc/
├── app-config.yaml              # Configuración principal de Backstage
├── app-config.production.yaml   # Configuración para producción
├── package.json                 # Dependencies
├── .env                         # Variables de entorno (crear)
├── examples/
│   └── argocd-template/         # Template de ArgoCD
│       ├── template.yaml        # Definición del template
│       ├── content/             # Archivos base
│       │   ├── Dockerfile
│       │   ├── catalog-info.yaml
│       │   └── .github/workflows/ci.yaml
│       ├── content-python/      # Archivos Python
│       └── gitops-values/       # Configuración GitOps
├── packages/
│   ├── app/                     # Frontend de Backstage
│   └── backend/                 # Backend de Backstage
└── charts/
    └── eks_baseline_chart-Helm-1/  # Helm chart transversal
```

## 🔐 Seguridad

- **No incluir tokens** en el código
- Usar **variables de entorno** para credenciales
- Configurar **GitHub Secrets** para CI/CD
- Usar **OIDC** para autenticación con AWS (sin credenciales estáticas)

## 🛠️ Configuración de ArgoCD

### Crear Proyectos en ArgoCD

```bash
# Proyecto dev
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: dev
  namespace: argocd
spec:
  destinations:
  - namespace: dev
    server: https://kubernetes.default.svc
  sourceRepos:
  - '*'
EOF
```

### Configurar App of Apps (opcional)

Ver documentación en: `CONFIGURAR_ARGOCD_APP_OF_APPS.md`

## 📚 Documentación Adicional

- `RESUMEN_EJECUTIVO_GERENCIA.md` - Resumen para gerencia
- `DEVELOPER_QUICK_START.md` - Guía rápida para desarrolladores
- `CONFIGURACION_ARGOCD_PLUGIN.md` - Configuración del plugin de ArgoCD
- `GUIA_CREAR_SCAFFOLDER.md` - Cómo crear templates personalizados

## 🐛 Troubleshooting

### Error 401 Unauthorized

Verifica que el `GITHUB_TOKEN` en `.env` sea válido y tenga los permisos necesarios.

### Backstage no inicia

```bash
# Verificar PostgreSQL
psql -U tu_usuario -d backstage -c "SELECT 1"

# Limpiar y reinstalar
rm -rf node_modules
yarn install
```

### ArgoCD no sincroniza

Verifica que:
- El repositorio gitops-apps exista
- ArgoCD tenga acceso al repositorio
- Los proyectos de ArgoCD estén configurados correctamente

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es de uso interno.

## 📞 Soporte

Para soporte o preguntas:
- Documentación: Este repositorio
- Issues: GitHub Issues
- Equipo: DevOps Team

---

**Nota**: Este README asume que tienes acceso a los recursos necesarios (AWS, GitHub, Kubernetes). Ajusta las configuraciones según tu entorno.
