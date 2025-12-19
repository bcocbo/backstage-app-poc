# Design Document

## Overview

Este diseño implementa un flujo completo de GitOps para Backstage que integra Software Templates, ArgoCD, CI/CD automatizado y un chart transversal de Helm. El sistema permite a los desarrolladores crear y desplegar servicios de manera self-service, siguiendo un proceso estandarizado y automatizado que va desde la creación del código hasta el despliegue en Kubernetes.

El flujo sigue estos pasos principales:
1. Desarrollador selecciona template en Backstage
2. Template crea repositorio de código con CI/CD
3. Template genera configuración GitOps con chart transversal
4. CI construye imagen y actualiza tag en GitOps
5. ArgoCD detecta cambios y despliega
6. Backstage muestra estado del despliegue

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         BACKSTAGE                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Software   │  │   Catalog    │  │   ArgoCD Plugin      │  │
│  │   Templates  │  │              │  │   (Status Display)   │  │
│  └──────┬───────┘  └──────────────┘  └──────────────────────┘  │
└─────────┼──────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB REPOSITORIES                           │
│  ┌──────────────────────┐      ┌──────────────────────────┐    │
│  │   App Repository     │      │   GitOps Repository      │    │
│  │  ┌────────────────┐  │      │  ┌────────────────────┐  │    │
│  │  │ Source Code    │  │      │  │ values/app-name/   │  │    │
│  │  │ Dockerfile     │  │      │  │   values.yaml      │  │    │
│  │  │ catalog-info   │  │      │  │ argocd/            │  │    │
│  │  │ .github/       │  │      │  │   application.yaml │  │    │
│  │  │   workflows/   │  │      │  └────────────────────┘  │    │
│  │  └────────┬───────┘  │      └──────────┬───────────────┘    │
│  └───────────┼──────────┘                 │                     │
└──────────────┼────────────────────────────┼─────────────────────┘
               │                            │
               ▼                            ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│   GitHub Actions CI      │    │      ArgoCD Server       │
│  ┌────────────────────┐  │    │  ┌────────────────────┐  │
│  │ 1. Build & Test    │  │    │  │ 1. Monitor GitOps  │  │
│  │ 2. Build Image     │  │    │  │ 2. Detect Changes  │  │
│  │ 3. Push to Registry│  │    │  │ 3. Sync to K8s     │  │
│  │ 4. Update GitOps   │──┼────┼─▶│ 4. Apply Resources │  │
│  └────────────────────┘  │    │  └────────────────────┘  │
└──────────────────────────┘    └──────────┬───────────────┘
                                           │
                                           ▼
                              ┌────────────────────────────┐
                              │   Kubernetes Cluster       │
                              │  ┌──────────────────────┐  │
                              │  │  Deployed Apps       │  │
                              │  │  (using transversal  │  │
                              │  │   Helm chart)        │  │
                              │  └──────────────────────┘  │
                              └────────────────────────────┘
```

### Component Interaction Flow

```
Developer → Backstage Template → GitHub (App Repo + GitOps Repo)
                                      ↓
                                 GitHub Actions CI
                                      ↓
                              Docker Registry + GitOps Update
                                      ↓
                                   ArgoCD
                                      ↓
                                  Kubernetes
                                      ↓
                              Backstage (Status Display)
```

## Components and Interfaces

### 1. Backstage Software Template

**Purpose:** Orquestar la creación de repositorios y configuración inicial

**Key Actions:**
- `fetch:template` - Generar archivos desde plantillas
- `publish:github` - Crear repositorio de aplicación
- `publish:github:pull-request` - Crear PR en repositorio GitOps
- `catalog:register` - Registrar componente en catálogo

**Input Parameters:**
```typescript
interface TemplateParameters {
  // App Info
  name: string;
  namespace: string;
  description: string;
  
  // Image Config
  image: string;
  imageTag: string;
  replicas: number;
  
  // Repositories
  repoUrl: string;
  gitopsRepoUrl: string;
  gitopsPath: string;
  gitopsBranch: string;
  
  // Environment
  environment: 'dev' | 'staging' | 'prod';
  
  // Chart Config
  chartVersion: string;
}
```

**Output:**
```typescript
interface TemplateOutput {
  links: {
    appRepo: string;
    gitopsPR: string;
    catalogEntity: string;
  };
  entityRef: string;
}
```

### 2. Chart Transversal (Helm Chart)

**Purpose:** Proporcionar estructura base reutilizable para todos los despliegues

**Location:** Repositorio centralizado de charts (ej: `org/helm-charts`)

**Structure:**
```
transversal-app-chart/
├── Chart.yaml
├── values.yaml (valores por defecto)
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── hpa.yaml
└── README.md
```

**Values Schema:**
```yaml
# values.yaml
app:
  name: ""
  namespace: ""
  
image:
  repository: ""
  tag: ""
  pullPolicy: IfNotPresent
  
replicas: 2

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: false
  className: nginx
  hosts: []
  tls: []

autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### 3. GitOps Repository Structure

**Purpose:** Almacenar configuración de despliegue separada del código

**Structure:**
```
gitops-repo/
├── charts/
│   └── transversal-app-chart/  (submodule o referencia)
├── values/
│   ├── dev/
│   │   ├── app-1/
│   │   │   └── values.yaml
│   │   └── app-2/
│   │       └── values.yaml
│   ├── staging/
│   └── prod/
├── argocd/
│   ├── app-of-apps.yaml
│   ├── projects/
│   │   ├── dev-project.yaml
│   │   ├── staging-project.yaml
│   │   └── prod-project.yaml
│   └── applications/
│       ├── dev/
│       │   ├── app-1.yaml
│       │   └── app-2.yaml
│       ├── staging/
│       └── prod/
└── README.md
```

### 4. GitHub Actions CI Workflow

**Purpose:** Construir imagen Docker y actualizar configuración GitOps

**Workflow File:** `.github/workflows/ci.yaml`

**Key Steps:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
      - name: Run linters
      - name: Run tests
      - name: Build Docker image
      - name: Scan image for vulnerabilities
      - name: Push to registry
      - name: Update GitOps repository
        # Actualiza imageTag en values.yaml
```

**GitOps Update Script:**
```bash
#!/bin/bash
# update-gitops.sh

GITOPS_REPO="$1"
APP_NAME="$2"
ENVIRONMENT="$3"
NEW_TAG="$4"

# Clone GitOps repo
git clone "$GITOPS_REPO" gitops-temp
cd gitops-temp

# Update values.yaml
yq eval ".image.tag = \"$NEW_TAG\"" -i "values/$ENVIRONMENT/$APP_NAME/values.yaml"

# Commit and push
git add .
git commit -m "chore: Update $APP_NAME image tag to $NEW_TAG"
git push origin main
```

### 5. ArgoCD Application Manifest

**Purpose:** Definir cómo ArgoCD debe desplegar la aplicación

**Template:**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .Values.name }}
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: {{ .Values.environment }}
  
  source:
    repoURL: {{ .Values.gitopsRepoUrl }}
    targetRevision: HEAD
    path: charts/transversal-app-chart
    helm:
      valueFiles:
        - ../../values/{{ .Values.environment }}/{{ .Values.name }}/values.yaml
  
  destination:
    server: https://kubernetes.default.svc
    namespace: {{ .Values.namespace }}
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

### 6. Backstage ArgoCD Plugin Integration

**Purpose:** Mostrar estado de ArgoCD en Backstage

**Configuration in app-config.yaml:**
```yaml
argocd:
  baseUrl: https://argocd.example.com
  username: ${ARGOCD_USERNAME}
  password: ${ARGOCD_PASSWORD}
  # O usar token
  token: ${ARGOCD_TOKEN}
  
  # Configuración de refresh
  waitCycles: 25
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argocd-prod
          url: https://argocd.example.com
```

**Annotation in catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-app
  annotations:
    argocd/app-name: my-app
    argocd/app-namespace: argocd
    argocd/instance-name: argocd-prod
spec:
  type: service
  lifecycle: production
  owner: team-a
```

## Data Models

### Component Entity (catalog-info.yaml)

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  description: My awesome service
  annotations:
    github.com/project-slug: org/my-service
    argocd/app-name: my-service
    argocd/app-namespace: argocd
  tags:
    - nodejs
    - api
  links:
    - url: https://my-service.example.com
      title: Production
      icon: dashboard
spec:
  type: service
  lifecycle: production
  owner: team-platform
  system: core-platform
  dependsOn:
    - resource:default/postgres-db
  providesApis:
    - my-service-api
```

### Values File Structure

```yaml
# values/dev/my-service/values.yaml
app:
  name: my-service
  namespace: dev
  
image:
  repository: ghcr.io/org/my-service
  tag: "sha-abc123"  # Actualizado por CI
  pullPolicy: Always
  
replicas: 2

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

service:
  type: ClusterIP
  port: 80
  targetPort: 3000

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: my-service-dev.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: my-service-tls
      hosts:
        - my-service-dev.example.com

env:
  - name: NODE_ENV
    value: development
  - name: LOG_LEVEL
    value: debug

secrets:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: my-service-secrets
        key: database-url
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property Reflection

After reviewing all testable properties, several can be consolidated:

**Consolidations:**
- Properties 2.2, 2.3, 2.4 (file existence checks) can be combined into "Repository structure completeness"
- Properties 3.1, 3.2, 3.3, 3.4 (values.yaml validation) can be combined into "Values file completeness"
- Properties 8.2, 8.3, 8.4 (ArgoCD card content) can be combined into "ArgoCD status display completeness"
- Properties 10.2, 10.3, 10.4, 10.5 (summary page links) can be combined into "Summary page completeness"

**Redundancies:**
- Property 2.5 (commit and push) is implied by 2.1 (repository creation)
- Property 6.3 (push after commit) is implied by 6.1 (GitOps update)
- Property 9.2 (process catalog-info) is implied by 9.3 (create entity)

### Correctness Properties

**Property 1: Template form validation**
*For any* template form submission, all required fields must be present and valid before the submission is accepted
**Validates: Requirements 1.3**

**Property 2: Repository structure completeness**
*For any* created application repository, it must contain catalog-info.yaml, CI/CD workflow files, and README.md with required content
**Validates: Requirements 2.2, 2.3, 2.4**

**Property 3: Values file completeness**
*For any* generated values.yaml file, it must reference the transversal chart and include all required fields (app name, namespace, image repository, image tag, replicas)
**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

**Property 4: ArgoCD Application manifest validity**
*For any* generated ArgoCD Application manifest, it must have valid source (chart reference), destination (namespace), and syncPolicy configuration
**Validates: Requirements 3.5**

**Property 5: GitOps Pull Request creation**
*For any* GitOps repository update, a Pull Request must be created with descriptive title, body containing app details, and notification sent to the developer
**Validates: Requirements 4.2, 4.3, 4.4**

**Property 6: Image tag update propagation**
*For any* Docker image published by CI, the corresponding values.yaml in GitOps repository must be updated with the new image tag within 5 minutes
**Validates: Requirements 6.1, 6.2, 6.3**

**Property 7: ArgoCD sync detection**
*For any* change in GitOps repository values.yaml, ArgoCD must detect the change and initiate sync within 3 minutes
**Validates: Requirements 7.1, 7.2**

**Property 8: Deployment namespace correctness**
*For any* ArgoCD sync operation, resources must be deployed to the namespace specified in the values.yaml
**Validates: Requirements 7.4**

**Property 9: Deployment health status**
*For any* completed ArgoCD deployment, the application status must be "Synced" and "Healthy" when all pods are running
**Validates: Requirements 7.5**

**Property 10: ArgoCD status display completeness**
*For any* component with ArgoCD annotations in Backstage, the ArgoCD card must display sync status, health status, and a valid link to ArgoCD UI
**Validates: Requirements 8.2, 8.3, 8.4**

**Property 11: Catalog registration completeness**
*For any* successful template execution, a Component entity must be created in the catalog with correct owner association and visible in catalog listings
**Validates: Requirements 9.1, 9.3, 9.4, 9.5**

**Property 12: Summary page completeness**
*For any* successful template execution, the summary page must include links to app repository, GitOps PR, catalog entity, and next steps instructions
**Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5**

**Property 13: Chart version specification**
*For any* ArgoCD Application manifest, it must specify an explicit version of the transversal chart (not "latest")
**Validates: Requirements 11.2**

**Property 14: CI validation ordering**
*For any* CI pipeline execution, linters and tests must run before Docker image build, and build must be skipped if validations fail
**Validates: Requirements 12.1, 12.2, 12.3, 12.4**

**Property 15: Environment-specific configuration**
*For any* template execution with environment selection, the generated values must be placed in the correct environment directory (values/{env}/{app-name}/) and contain environment-specific settings
**Validates: Requirements 13.2, 13.5**

## Error Handling

### Template Execution Errors

**GitHub API Failures:**
- **Scenario:** GitHub API returns 4xx or 5xx errors during repository creation
- **Handling:** 
  - Retry up to 3 times with exponential backoff
  - If all retries fail, rollback any partial changes
  - Display clear error message to user with GitHub status
  - Log full error details for debugging

**GitOps Repository Access Errors:**
- **Scenario:** Cannot clone or push to GitOps repository
- **Handling:**
  - Verify credentials and permissions
  - Check if repository exists and is accessible
  - Provide clear error message about permission requirements
  - Do not create app repository if GitOps update will fail

**Validation Errors:**
- **Scenario:** User input fails validation rules
- **Handling:**
  - Display inline validation errors on form fields
  - Prevent form submission until all errors are resolved
  - Provide helpful error messages with examples
  - Validate on both client and server side

### CI/CD Pipeline Errors

**Build Failures:**
- **Scenario:** Docker build fails due to code errors
- **Handling:**
  - Stop pipeline immediately
  - Display build logs in GitHub Actions UI
  - Send notification to developer
  - Do not update GitOps repository

**Registry Push Failures:**
- **Scenario:** Cannot push image to container registry
- **Handling:**
  - Retry push up to 3 times
  - Check registry credentials and quotas
  - Log detailed error information
  - Fail pipeline if push cannot complete

**GitOps Update Failures:**
- **Scenario:** Cannot update values.yaml in GitOps repo
- **Handling:**
  - Retry update up to 3 times
  - Check for merge conflicts
  - Create issue in GitOps repo if automatic update fails
  - Notify platform team for manual intervention

### ArgoCD Sync Errors

**Sync Failures:**
- **Scenario:** ArgoCD cannot sync application to cluster
- **Handling:**
  - Display error details in ArgoCD UI and Backstage
  - Retry sync automatically based on retry policy
  - Alert platform team if sync fails repeatedly
  - Provide rollback option to previous version

**Health Check Failures:**
- **Scenario:** Deployed application is not healthy
- **Handling:**
  - Display pod status and logs in ArgoCD
  - Trigger automatic rollback if health check fails for > 5 minutes
  - Send alert to development team
  - Provide debugging information in Backstage

**Resource Conflicts:**
- **Scenario:** Kubernetes resources already exist with different configuration
- **Handling:**
  - Use ArgoCD's prune and replace options
  - Log conflict details
  - Require manual resolution for production environments
  - Allow automatic resolution for dev environments

### Backstage Plugin Errors

**ArgoCD API Connection Errors:**
- **Scenario:** Cannot connect to ArgoCD API
- **Handling:**
  - Display "ArgoCD Unavailable" message in card
  - Retry connection with exponential backoff
  - Cache last known status for display
  - Log connection errors for monitoring

**Catalog Registration Errors:**
- **Scenario:** Cannot register component in catalog
- **Handling:**
  - Retry registration up to 3 times
  - Validate catalog-info.yaml syntax
  - Display validation errors to user
  - Provide manual registration instructions if automatic fails

## Testing Strategy

### Unit Testing

**Backstage Template Actions:**
- Test each template action in isolation
- Mock GitHub API calls
- Verify correct parameters are passed
- Test error handling for API failures

**Values File Generation:**
- Test YAML generation with various inputs
- Verify all required fields are present
- Test environment-specific value overrides
- Validate YAML syntax

**GitOps Update Script:**
- Test yq commands for updating values
- Verify git operations (clone, commit, push)
- Test error handling for merge conflicts
- Mock git commands for testing

### Property-Based Testing

We will use **fast-check** (for TypeScript/JavaScript) as our property-based testing library, configured to run a minimum of 100 iterations per property.

**Property Test 1: Template form validation**
```typescript
// Feature: backstage-argocd-gitops-flow, Property 1: Template form validation
// Validates: Requirements 1.3
fc.assert(
  fc.property(
    fc.record({
      name: fc.string(),
      namespace: fc.string(),
      image: fc.string(),
      // ... other fields
    }),
    (formData) => {
      const result = validateTemplateForm(formData);
      // If all required fields are present and valid, validation should pass
      const hasRequiredFields = formData.name && formData.namespace && formData.image;
      const areFieldsValid = isValidName(formData.name) && isValidNamespace(formData.namespace);
      
      if (hasRequiredFields && areFieldsValid) {
        expect(result.valid).toBe(true);
      } else {
        expect(result.valid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
      }
    }
  ),
  { numRuns: 100 }
);
```

**Property Test 2: Repository structure completeness**
```typescript
// Feature: backstage-argocd-gitops-flow, Property 2: Repository structure completeness
// Validates: Requirements 2.2, 2.3, 2.4
fc.assert(
  fc.property(
    fc.record({
      name: fc.string({ minLength: 1, maxLength: 50 }),
      description: fc.string(),
      owner: fc.string(),
    }),
    async (params) => {
      const repo = await createRepository(params);
      
      // Check required files exist
      expect(await repo.fileExists('catalog-info.yaml')).toBe(true);
      expect(await repo.fileExists('.github/workflows/ci.yaml')).toBe(true);
      expect(await repo.fileExists('README.md')).toBe(true);
      
      // Verify catalog-info.yaml has required fields
      const catalogInfo = await repo.readYaml('catalog-info.yaml');
      expect(catalogInfo.metadata.name).toBe(params.name);
      expect(catalogInfo.spec.owner).toBe(params.owner);
    }
  ),
  { numRuns: 100 }
);
```

**Property Test 3: Values file completeness**
```typescript
// Feature: backstage-argocd-gitops-flow, Property 3: Values file completeness
// Validates: Requirements 3.1, 3.2, 3.3, 3.4
fc.assert(
  fc.property(
    fc.record({
      name: fc.string({ minLength: 1 }),
      namespace: fc.string({ minLength: 1 }),
      image: fc.string({ minLength: 1 }),
      imageTag: fc.string({ minLength: 1 }),
      replicas: fc.integer({ min: 1, max: 10 }),
    }),
    (params) => {
      const values = generateValuesFile(params);
      
      // Must reference transversal chart
      expect(values.chart).toContain('transversal-app-chart');
      
      // Must include all required fields
      expect(values.app.name).toBe(params.name);
      expect(values.app.namespace).toBe(params.namespace);
      expect(values.image.repository).toBe(params.image);
      expect(values.image.tag).toBe(params.imageTag);
      expect(values.replicas).toBe(params.replicas);
    }
  ),
  { numRuns: 100 }
);
```

**Property Test 6: Image tag update propagation**
```typescript
// Feature: backstage-argocd-gitops-flow, Property 6: Image tag update propagation
// Validates: Requirements 6.1, 6.2, 6.3
fc.assert(
  fc.property(
    fc.record({
      appName: fc.string({ minLength: 1 }),
      environment: fc.constantFrom('dev', 'staging', 'prod'),
      oldTag: fc.string({ minLength: 1 }),
      newTag: fc.string({ minLength: 1 }),
    }),
    async (params) => {
      // Setup: Create values file with old tag
      await setupValuesFile(params.appName, params.environment, params.oldTag);
      
      // Action: Trigger CI pipeline with new tag
      await triggerCIPipeline(params.appName, params.newTag);
      
      // Wait for update (max 5 minutes)
      await waitForUpdate(5 * 60 * 1000);
      
      // Verify: values.yaml should have new tag
      const values = await readValuesFile(params.appName, params.environment);
      expect(values.image.tag).toBe(params.newTag);
      
      // Verify: Commit message should be descriptive
      const lastCommit = await getLastCommit();
      expect(lastCommit.message).toContain(params.appName);
      expect(lastCommit.message).toContain(params.newTag);
    }
  ),
  { numRuns: 100 }
);
```

**Property Test 15: Environment-specific configuration**
```typescript
// Feature: backstage-argocd-gitops-flow, Property 15: Environment-specific configuration
// Validates: Requirements 13.2, 13.5
fc.assert(
  fc.property(
    fc.record({
      appName: fc.string({ minLength: 1 }),
      environment: fc.constantFrom('dev', 'staging', 'prod'),
    }),
    (params) => {
      const config = generateEnvironmentConfig(params.appName, params.environment);
      
      // Must be in correct directory
      expect(config.path).toBe(`values/${params.environment}/${params.appName}/values.yaml`);
      
      // Must have environment-specific values
      const envDefaults = getEnvironmentDefaults(params.environment);
      expect(config.values.app.namespace).toBe(envDefaults.namespace);
      expect(config.values.resources).toEqual(envDefaults.resources);
      
      // Production should have higher resources
      if (params.environment === 'prod') {
        expect(config.values.replicas).toBeGreaterThanOrEqual(2);
        expect(config.values.resources.limits.cpu).toContain('m');
      }
    }
  ),
  { numRuns: 100 }
);
```

### Integration Testing

**End-to-End Template Execution:**
- Test complete flow from template selection to deployment
- Use test GitHub organization and repositories
- Verify all steps complete successfully
- Test rollback on failures

**ArgoCD Integration:**
- Test ArgoCD application creation
- Verify sync behavior with test cluster
- Test health checks and status reporting
- Verify Backstage plugin displays correct status

**CI/CD Pipeline:**
- Test complete pipeline execution
- Verify image build and push
- Test GitOps repository updates
- Verify ArgoCD detects changes

### Manual Testing Checklist

- [ ] Template appears in Backstage UI with correct metadata
- [ ] Form validation works for all fields
- [ ] Repository creation succeeds with all required files
- [ ] GitOps PR is created with correct content
- [ ] CI pipeline triggers automatically
- [ ] Image is built and pushed to registry
- [ ] GitOps repository is updated with new tag
- [ ] ArgoCD detects change and syncs
- [ ] Application deploys successfully to Kubernetes
- [ ] Backstage shows correct ArgoCD status
- [ ] Component appears in catalog
- [ ] Summary page shows all links correctly

## Implementation Notes

### Prerequisites

1. **Backstage Setup:**
   - Backstage instance running with PostgreSQL
   - GitHub integration configured
   - ArgoCD plugin installed and configured

2. **GitHub:**
   - GitHub organization for repositories
   - Personal Access Token with repo permissions
   - GitHub Actions enabled

3. **ArgoCD:**
   - ArgoCD installed in Kubernetes cluster
   - API access configured
   - App-of-Apps pattern set up

4. **Container Registry:**
   - Registry accessible from CI (GitHub Container Registry, Docker Hub, etc.)
   - Credentials configured in GitHub Secrets

5. **Kubernetes Cluster:**
   - Cluster accessible by ArgoCD
   - Namespaces created for environments
   - RBAC configured

### Configuration Files

**app-config.yaml additions:**
```yaml
scaffolder:
  defaultAuthor:
    name: Backstage
    email: backstage@example.com
  defaultCommitMessage: 'Initial commit from Backstage'

integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

argocd:
  baseUrl: https://argocd.example.com
  username: ${ARGOCD_USERNAME}
  password: ${ARGOCD_PASSWORD}
  waitCycles: 25

catalog:
  rules:
    - allow: [Component, System, API, Resource, Location, Template]
  locations:
    - type: file
      target: ../../examples/argocd-template/template.yaml
      rules:
        - allow: [Template]
```

### Deployment Sequence

1. **Phase 1: Setup Infrastructure**
   - Deploy ArgoCD to cluster
   - Create GitOps repository
   - Set up transversal Helm chart
   - Configure Backstage with ArgoCD plugin

2. **Phase 2: Create Template**
   - Develop template.yaml
   - Create template content files
   - Test template in development

3. **Phase 3: CI/CD Integration**
   - Create GitHub Actions workflow template
   - Implement GitOps update script
   - Test image build and push

4. **Phase 4: ArgoCD Configuration**
   - Create App-of-Apps structure
   - Configure sync policies
   - Test deployment to cluster

5. **Phase 5: Backstage Integration**
   - Configure ArgoCD plugin
   - Test status display
   - Verify catalog registration

6. **Phase 6: Testing & Validation**
   - Run property-based tests
   - Execute integration tests
   - Perform manual testing
   - Document any issues

### Security Considerations

- Store all secrets in GitHub Secrets or Kubernetes Secrets
- Use least-privilege RBAC for ArgoCD
- Scan Docker images for vulnerabilities
- Implement approval gates for production deployments
- Audit all template executions
- Rotate credentials regularly
- Use signed commits for GitOps repository
