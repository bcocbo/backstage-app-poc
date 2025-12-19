# Guía: Crear un Scaffolder Template en Backstage

## 📋 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Anatomía de un Template](#anatomía-de-un-template)
3. [Paso a Paso: Crear tu Template](#paso-a-paso-crear-tu-template)
4. [Componentes del Template](#componentes-del-template)
5. [Actions Disponibles](#actions-disponibles)
6. [Ejemplos Prácticos](#ejemplos-prácticos)
7. [Testing y Debugging](#testing-y-debugging)
8. [Best Practices](#best-practices)

---

## Introducción

Los **Scaffolder Templates** en Backstage permiten automatizar la creación de proyectos, repositorios y configuraciones. Son como "recetas" que guían a los desarrolladores a través de un formulario y generan todo el código necesario automáticamente.

### ¿Qué puedes hacer con un Template?

- ✅ Crear repositorios en GitHub/GitLab
- ✅ Generar código desde plantillas
- ✅ Configurar CI/CD pipelines
- ✅ Crear Pull Requests
- ✅ Registrar componentes en el catálogo
- ✅ Ejecutar scripts personalizados
- ✅ Integrar con APIs externas

---

## Anatomía de un Template

Un template de Backstage tiene esta estructura:

```
my-template/
├── template.yaml          # Definición del template (metadata, parámetros, steps)
├── content/              # Archivos que se generarán
│   ├── README.md
│   ├── src/
│   │   └── index.js
│   ├── Dockerfile
│   └── catalog-info.yaml
└── README.md             # Documentación del template
```

### Archivo Principal: `template.yaml`

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: mi-template
  title: Mi Template Awesome
  description: Crea una aplicación Node.js con CI/CD
  tags:
    - nodejs
    - recommended
spec:
  owner: user:guest
  type: service
  
  parameters:
    # Formulario que verá el usuario
    
  steps:
    # Pasos de ejecución
    
  output:
    # Links y mensajes finales
```

---

## Paso a Paso: Crear tu Template

### Paso 1: Crear la Estructura

```bash
# Crear directorio del template
mkdir -p examples/my-template/content

# Crear archivos base
touch examples/my-template/template.yaml
touch examples/my-template/README.md
```

### Paso 2: Definir Metadata

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: nodejs-app-template
  title: Node.js Application
  description: Crea una aplicación Node.js con Express y CI/CD
  tags:
    - nodejs
    - express
    - recommended
spec:
  owner: user:guest
  type: service
```

**Campos importantes:**
- `name`: ID único del template (kebab-case)
- `title`: Nombre visible en la UI
- `description`: Descripción corta
- `tags`: Para filtrar y buscar
- `owner`: Dueño del template
- `type`: Tipo de componente (service, website, library, etc.)

### Paso 3: Definir Parámetros (Formulario)

Los parámetros definen el formulario que verá el usuario:

```yaml
parameters:
  - title: Información Básica
    required:
      - name
      - owner
    properties:
      name:
        title: Nombre del Proyecto
        type: string
        description: Nombre único para tu aplicación
        ui:autofocus: true
        pattern: '^[a-z0-9-]+$'
        
      owner:
        title: Owner
        type: string
        description: Dueño del componente
        ui:field: OwnerPicker
        ui:options:
          allowedKinds:
            - Group
            - User
            
      description:
        title: Descripción
        type: string
        description: Describe tu aplicación
        
  - title: Configuración
    properties:
      port:
        title: Puerto
        type: number
        default: 3000
        description: Puerto donde correrá la aplicación
        
      database:
        title: Base de Datos
        type: string
        enum:
          - postgres
          - mysql
          - mongodb
        enumNames:
          - PostgreSQL
          - MySQL
          - MongoDB
```

**Tipos de campos:**
- `string`: Texto
- `number`: Números
- `boolean`: Checkbox
- `array`: Lista de valores
- `object`: Objeto anidado

**UI Fields especiales:**
- `RepoUrlPicker`: Selector de repositorio
- `OwnerPicker`: Selector de owner
- `EntityPicker`: Selector de entidad del catálogo
- `OwnedEntityPicker`: Selector de entidades propias

### Paso 4: Definir Steps (Acciones)

Los steps son las acciones que ejecutará el template:

```yaml
steps:
  # 1. Obtener template base
  - id: fetch-base
    name: Fetch Base Template
    action: fetch:template
    input:
      url: ./content
      values:
        name: ${{ parameters.name }}
        owner: ${{ parameters.owner }}
        port: ${{ parameters.port }}
        database: ${{ parameters.database }}
        
  # 2. Publicar en GitHub
  - id: publish
    name: Publish to GitHub
    action: publish:github
    input:
      description: ${{ parameters.description }}
      repoUrl: ${{ parameters.repoUrl }}
      defaultBranch: main
      
  # 3. Registrar en catálogo
  - id: register
    name: Register Component
    action: catalog:register
    input:
      repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
      catalogInfoPath: '/catalog-info.yaml'
```

### Paso 5: Definir Output

El output muestra links y mensajes al usuario después de ejecutar el template:

```yaml
output:
  links:
    - title: Repositorio
      url: ${{ steps['publish'].output.remoteUrl }}
    - title: Ver en Catálogo
      icon: catalog
      entityRef: ${{ steps['register'].output.entityRef }}
      
  text:
    - title: Próximos Pasos
      content: |
        1. Clona el repositorio
        2. Instala dependencias: npm install
        3. Inicia la app: npm start
```

### Paso 6: Crear Contenido del Template

Crea archivos en `content/` usando sintaxis de template:

**content/README.md:**
```markdown
# ${{ values.name }}

${{ values.description }}

## Configuración

- Puerto: ${{ values.port }}
- Base de datos: ${{ values.database }}
- Owner: ${{ values.owner }}

## Instalación

\```bash
npm install
npm start
\```
```

**content/package.json:**
```json
{
  "name": "${{ values.name }}",
  "version": "1.0.0",
  "description": "${{ values.description }}",
  "main": "index.js",
  "scripts": {
    "start": "node src/index.js"
  }
}
```

**content/catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.name }}
  description: ${{ values.description }}
  annotations:
    github.com/project-slug: ${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}
spec:
  type: service
  lifecycle: experimental
  owner: ${{ values.owner }}
```

### Paso 7: Registrar el Template

Agrega el template al catálogo en `app-config.yaml`:

```yaml
catalog:
  locations:
    - type: file
      target: ../../examples/my-template/template.yaml
      rules:
        - allow: [Template]
```

O crea un `catalog-info.yaml` en el directorio del template:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: my-templates
  description: My custom templates
spec:
  targets:
    - ./template.yaml
```

---

## Componentes del Template

### 1. Conditional Rendering

Mostrar campos basados en otros valores:

```yaml
parameters:
  - title: Tipo de App
    properties:
      appType:
        title: Tipo
        type: string
        enum:
          - web
          - api
    dependencies:
      appType:
        oneOf:
          - properties:
              appType:
                enum: [web]
              framework:
                title: Framework
                type: string
                enum:
                  - react
                  - vue
          - properties:
              appType:
                enum: [api]
              apiType:
                title: Tipo de API
                type: string
                enum:
                  - rest
                  - graphql
```

### 2. Validación

```yaml
properties:
  name:
    title: Nombre
    type: string
    pattern: '^[a-z0-9-]+$'
    minLength: 3
    maxLength: 50
    
  email:
    title: Email
    type: string
    format: email
    
  port:
    title: Puerto
    type: number
    minimum: 1024
    maximum: 65535
```

### 3. Valores por Defecto

```yaml
properties:
  environment:
    title: Entorno
    type: string
    default: dev
    enum:
      - dev
      - staging
      - prod
```

### 4. Campos Condicionales en Templates

**content/Dockerfile:**
```dockerfile
FROM node:18-alpine

{% if values.database == 'postgres' %}
RUN apk add --no-cache postgresql-client
{% endif %}

{% if values.database == 'mysql' %}
RUN apk add --no-cache mysql-client
{% endif %}

WORKDIR /app
COPY . .
RUN npm install

EXPOSE ${{ values.port }}
CMD ["npm", "start"]
```

---

## Actions Disponibles

### Core Actions

#### 1. `fetch:template`
Copia archivos del template y reemplaza variables:

```yaml
- id: fetch
  name: Fetch Template
  action: fetch:template
  input:
    url: ./content
    values:
      name: ${{ parameters.name }}
```

#### 2. `fetch:plain`
Copia archivos sin procesar:

```yaml
- id: fetch-docs
  name: Fetch Documentation
  action: fetch:plain
  input:
    url: ./docs
    targetPath: ./docs
```

#### 3. `publish:github`
Crea un repositorio en GitHub:

```yaml
- id: publish
  name: Publish to GitHub
  action: publish:github
  input:
    description: ${{ parameters.description }}
    repoUrl: ${{ parameters.repoUrl }}
    defaultBranch: main
    repoVisibility: public
    deleteBranchOnMerge: true
    gitAuthorName: Backstage
    gitAuthorEmail: backstage@example.com
```

#### 4. `publish:github:pull-request`
Crea un Pull Request:

```yaml
- id: create-pr
  name: Create Pull Request
  action: publish:github:pull-request
  input:
    repoUrl: github.com?repo=my-repo&owner=my-org
    branchName: feature-${{ parameters.name }}
    title: 'Add ${{ parameters.name }}'
    description: |
      ## Changes
      - Added new feature
    sourcePath: .
    targetPath: apps/${{ parameters.name }}
```

#### 5. `catalog:register`
Registra componente en el catálogo:

```yaml
- id: register
  name: Register Component
  action: catalog:register
  input:
    repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
    catalogInfoPath: '/catalog-info.yaml'
```

#### 6. `catalog:write`
Escribe directamente en el catálogo:

```yaml
- id: catalog-write
  name: Write to Catalog
  action: catalog:write
  input:
    entity:
      apiVersion: backstage.io/v1alpha1
      kind: Component
      metadata:
        name: ${{ parameters.name }}
      spec:
        type: service
        owner: ${{ parameters.owner }}
```

#### 7. `fs:rename`
Renombra archivos:

```yaml
- id: rename
  name: Rename Files
  action: fs:rename
  input:
    files:
      - from: template.env
        to: .env
```

#### 8. `fs:delete`
Elimina archivos:

```yaml
- id: cleanup
  name: Cleanup
  action: fs:delete
  input:
    files:
      - .template
      - temp/
```

### GitHub Actions

#### 9. `github:actions:dispatch`
Dispara un workflow de GitHub Actions:

```yaml
- id: trigger-ci
  name: Trigger CI
  action: github:actions:dispatch
  input:
    repoUrl: github.com?repo=my-repo&owner=my-org
    workflowId: ci.yml
    branchOrTagName: main
```

### Utility Actions

#### 10. `debug:log`
Imprime valores para debugging:

```yaml
- id: debug
  name: Debug Values
  action: debug:log
  input:
    message: 'Name: ${{ parameters.name }}, Owner: ${{ parameters.owner }}'
```

---

## Ejemplos Prácticos

### Ejemplo 1: Template Simple de Node.js

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: simple-nodejs
  title: Simple Node.js App
  description: Crea una app Node.js básica
spec:
  owner: user:guest
  type: service
  
  parameters:
    - title: Información
      required:
        - name
      properties:
        name:
          title: Nombre
          type: string
        repoUrl:
          title: Repositorio
          type: string
          ui:field: RepoUrlPicker
          ui:options:
            allowedHosts:
              - github.com
              
  steps:
    - id: fetch
      name: Fetch Template
      action: fetch:template
      input:
        url: ./content
        values:
          name: ${{ parameters.name }}
          
    - id: publish
      name: Publish
      action: publish:github
      input:
        repoUrl: ${{ parameters.repoUrl }}
        
    - id: register
      name: Register
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
  output:
    links:
      - title: Repositorio
        url: ${{ steps['publish'].output.remoteUrl }}
```

### Ejemplo 2: Template con Pull Request

```yaml
steps:
  - id: fetch
    name: Fetch Template
    action: fetch:template
    input:
      url: ./content
      values:
        name: ${{ parameters.name }}
        
  - id: pr
    name: Create PR
    action: publish:github:pull-request
    input:
      repoUrl: github.com?repo=monorepo&owner=myorg
      branchName: add-${{ parameters.name }}
      title: 'feat: Add ${{ parameters.name }}'
      description: |
        ## New Service: ${{ parameters.name }}
        
        Created by Backstage template.
      sourcePath: .
      targetPath: services/${{ parameters.name }}
```

### Ejemplo 3: Template Multi-Repo

```yaml
steps:
  # Crear repo de aplicación
  - id: fetch-app
    name: Fetch App Template
    action: fetch:template
    input:
      url: ./app-content
      values:
        name: ${{ parameters.name }}
        
  - id: publish-app
    name: Publish App
    action: publish:github
    input:
      repoUrl: ${{ parameters.appRepoUrl }}
      
  # Crear PR en repo de configuración
  - id: fetch-config
    name: Fetch Config
    action: fetch:template
    input:
      url: ./config-content
      values:
        name: ${{ parameters.name }}
        appRepo: ${{ steps['publish-app'].output.remoteUrl }}
        
  - id: pr-config
    name: Create Config PR
    action: publish:github:pull-request
    input:
      repoUrl: github.com?repo=config&owner=myorg
      branchName: add-${{ parameters.name }}
      title: 'config: Add ${{ parameters.name }}'
```

---

## Testing y Debugging

### 1. Dry Run Local

Usa el CLI de Backstage para probar templates:

```bash
# Instalar CLI
npm install -g @backstage/cli

# Ejecutar template localmente
backstage-cli create --template ./examples/my-template
```

### 2. Debug con `debug:log`

Agrega steps de debug:

```yaml
steps:
  - id: debug-params
    name: Debug Parameters
    action: debug:log
    input:
      message: |
        Name: ${{ parameters.name }}
        Owner: ${{ parameters.owner }}
        RepoUrl: ${{ parameters.repoUrl }}
        
  - id: fetch
    name: Fetch Template
    action: fetch:template
    input:
      url: ./content
      values:
        name: ${{ parameters.name }}
        
  - id: debug-output
    name: Debug Output
    action: debug:log
    input:
      message: 'Files created: ${{ steps["fetch"].output.files }}'
```

### 3. Validar YAML

```bash
# Validar sintaxis YAML
yamllint examples/my-template/template.yaml

# O usar un validador online
# https://www.yamllint.com/
```

### 4. Revisar Logs

Los logs de Backstage muestran errores detallados:

```bash
# Iniciar con logs detallados
yarn start --verbose

# O revisar logs del backend
tail -f packages/backend/dist/index.cjs.log
```

### 5. Test en Desarrollo

1. Registra el template en `app-config.yaml`
2. Reinicia Backstage
3. Ve a "Create" en la UI
4. Prueba el formulario
5. Revisa los archivos generados

---

## Best Practices

### 1. Naming Conventions

```yaml
# ✅ BIEN
metadata:
  name: nodejs-express-api
  title: Node.js Express API
  
# ❌ MAL
metadata:
  name: NodeJsExpressAPI
  title: nodejs express api
```

### 2. Documentación Clara

```yaml
properties:
  name:
    title: Nombre del Proyecto
    type: string
    description: Nombre único en kebab-case (ej. my-awesome-app)
    pattern: '^[a-z0-9-]+$'
    ui:help: 'Solo minúsculas, números y guiones'
```

### 3. Validación Robusta

```yaml
properties:
  name:
    title: Nombre
    type: string
    pattern: '^[a-z0-9-]+$'
    minLength: 3
    maxLength: 50
    
  port:
    title: Puerto
    type: number
    minimum: 1024
    maximum: 65535
    default: 3000
```

### 4. Valores por Defecto Sensatos

```yaml
properties:
  environment:
    title: Entorno
    type: string
    default: dev  # ✅ Valor seguro por defecto
    enum:
      - dev
      - staging
      - prod
      
  replicas:
    title: Réplicas
    type: number
    default: 2  # ✅ Valor razonable
    minimum: 1
    maximum: 10
```

### 5. Mensajes de Error Útiles

```yaml
output:
  text:
    - title: ⚠️ Importante
      content: |
        Antes de continuar:
        1. Aprueba el PR en el repo de configuración
        2. Espera a que CI/CD termine
        3. Verifica el despliegue en ArgoCD
        
    - title: 🔗 Links Útiles
      content: |
        - [Documentación](https://docs.example.com)
        - [Soporte](https://support.example.com)
```

### 6. Estructura Modular

```
templates/
├── nodejs/
│   ├── template.yaml
│   ├── content/
│   └── README.md
├── python/
│   ├── template.yaml
│   ├── content/
│   └── README.md
└── shared/
    ├── ci-cd/
    └── docs/
```

### 7. Reutilización de Contenido

```yaml
steps:
  # Fetch base común
  - id: fetch-base
    name: Fetch Base
    action: fetch:template
    input:
      url: ../../shared/base
      
  # Fetch específico del lenguaje
  - id: fetch-language
    name: Fetch Language Specific
    action: fetch:template
    input:
      url: ./content
```

### 8. Seguridad

```yaml
# ✅ BIEN - Usar secrets
steps:
  - id: publish
    name: Publish
    action: publish:github
    input:
      token: ${{ secrets.GITHUB_TOKEN }}
      
# ❌ MAL - Hardcodear tokens
steps:
  - id: publish
    name: Publish
    action: publish:github
    input:
      token: ghp_xxxxxxxxxxxx
```

### 9. Testing Completo

Antes de publicar un template:

- ✅ Probar todos los paths del formulario
- ✅ Validar con diferentes valores
- ✅ Verificar archivos generados
- ✅ Probar en diferentes entornos
- ✅ Revisar permisos de GitHub
- ✅ Documentar casos especiales

### 10. Versionado

```yaml
metadata:
  name: nodejs-app-v2
  title: Node.js App (v2)
  description: Node.js app template - Version 2.0
  tags:
    - nodejs
    - v2
    - recommended
  annotations:
    backstage.io/version: '2.0.0'
```

---

## Recursos Adicionales

### Documentación Oficial

- [Backstage Software Templates](https://backstage.io/docs/features/software-templates/)
- [Template Actions](https://backstage.io/docs/features/software-templates/builtin-actions)
- [Writing Templates](https://backstage.io/docs/features/software-templates/writing-templates)

### Ejemplos de la Comunidad

- [Backstage Templates Repository](https://github.com/backstage/software-templates)
- [Roadie Templates](https://github.com/RoadieHQ/software-templates)

### Tools

- [YAML Validator](https://www.yamllint.com/)
- [JSON Schema Validator](https://www.jsonschemavalidator.net/)
- [Nunjucks Template Tester](https://mozilla.github.io/nunjucks/)

---

## Troubleshooting Común

### Error: "Template not found"

**Causa**: Template no registrado en el catálogo

**Solución**:
```yaml
# app-config.yaml
catalog:
  locations:
    - type: file
      target: ../../examples/my-template/template.yaml
```

### Error: "Invalid parameter"

**Causa**: Validación fallida

**Solución**: Revisar `pattern`, `minLength`, `maxLength`, etc.

### Error: "GitHub token invalid"

**Causa**: Token sin permisos o expirado

**Solución**:
1. Generar nuevo token en GitHub
2. Dar permisos: `repo`, `workflow`
3. Actualizar en `.env` o `app-config.yaml`

### Error: "Failed to publish"

**Causa**: Repositorio ya existe

**Solución**: Usar nombre diferente o eliminar repo existente

---

## Conclusión

Crear templates en Backstage es poderoso pero requiere:

1. ✅ Entender la estructura YAML
2. ✅ Conocer las actions disponibles
3. ✅ Diseñar buenos formularios
4. ✅ Validar inputs
5. ✅ Documentar bien
6. ✅ Probar exhaustivamente

Con esta guía tienes todo lo necesario para crear templates profesionales que automaticen la creación de proyectos en tu organización.

**¡Feliz scaffolding! 🚀**
