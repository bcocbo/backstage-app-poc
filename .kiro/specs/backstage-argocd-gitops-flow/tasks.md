# Implementation Plan

## Current State Analysis

The codebase currently has:
- ✅ Basic Backstage setup with PostgreSQL
- ✅ GitHub integration configured
- ✅ ArgoCD frontend plugin installed (`@roadiehq/backstage-plugin-argo-cd`)
- ✅ Complete template structure in `examples/argocd-template/`
- ✅ Template content files (catalog-info.yaml, Dockerfile, README)
- ✅ GitOps values structure (values.yaml, argocd-application.yaml)
- ✅ Kubernetes plugin installed and configured
- ✅ **Transversal Helm chart created** (`eks_baseline_chart_Helm`)
- ✅ **GitOps repository structured** (`gitops-apps`)
- ✅ **CI/CD workflow template** (.github/workflows/ci.yaml)
- ✅ **GitOps update script** integrated in CI pipeline
- ✅ **Environment-specific configuration** (dev/staging/prod)
- ✅ **Two application types** (prebuilt/custom with 5 languages)
- ✅ **GitHub token configured** (hardcoded temporarily)

Missing/Incomplete:
- ✅ ArgoCD backend plugin configured
- ✅ ArgoCD plugin integrated in EntityPage
- ✅ ArgoCD configuration in app-config.yaml
- ❌ Property-based tests
- ❌ Integration tests
- ⚠️ GitHub token needs to be moved back to environment variables

---

## Implementation Tasks

- [x] 1. Configure ArgoCD integration in Backstage
  - ✅ Install and configure ArgoCD backend plugin
  - ✅ Add ArgoCD configuration to app-config.yaml (baseUrl, credentials)
  - ✅ Configure ArgoCD proxy endpoint if needed
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 1.1 Add ArgoCD backend plugin to backend
  - ✅ Installed `@roadiehq/backstage-plugin-argo-cd-backend` package
  - ✅ Added plugin to `packages/backend/src/index.ts`
  - ✅ Configured environment variables for ArgoCD credentials in `.env`
  - _Requirements: 8.1_

- [x] 1.2 Update app-config.yaml with ArgoCD settings
  - ✅ Added `argocd` section with baseUrl and token authentication
  - ✅ Configured waitCycles and appLocatorMethods
  - ✅ Added support for multiple ArgoCD instances
  - _Requirements: 8.1_

- [x] 1.3 Integrate ArgoCD card in EntityPage
  - ✅ Imported ArgoCD components in `packages/app/src/components/catalog/EntityPage.tsx`
  - ✅ Added `EntityArgoCDOverviewCard` to service entity overview
  - ✅ Added ArgoCD tab with overview and history cards
  - ✅ Added conditional rendering with `isArgocdAvailable`
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ]* 1.4 Write property test for ArgoCD status display
  - **Property 10: ArgoCD status display completeness**
  - **Validates: Requirements 8.2, 8.3, 8.4**

- [ ] 2. Create transversal Helm chart
  - Create Helm chart repository structure
  - Implement base chart with deployment, service, ingress, configmap templates
  - Define comprehensive values.yaml schema
  - Document chart usage and customization
  - _Requirements: 3.2, 7.3, 11.1, 11.2, 11.4_

- [ ] 2.1 Set up Helm chart directory structure
  - Create `charts/transversal-app-chart/` directory
  - Create `Chart.yaml` with metadata and version
  - Create default `values.yaml` with all configurable options
  - Create `README.md` with chart documentation
  - _Requirements: 11.1, 11.4_

- [ ] 2.2 Implement Helm templates
  - Create `templates/deployment.yaml` with pod spec
  - Create `templates/service.yaml` for service exposure
  - Create `templates/ingress.yaml` for external access
  - Create `templates/configmap.yaml` for configuration
  - Create `templates/hpa.yaml` for autoscaling
  - Create `templates/_helpers.tpl` for template functions
  - _Requirements: 3.2, 7.3_

- [ ] 2.3 Add chart versioning and CHANGELOG
  - Implement semantic versioning in Chart.yaml
  - Create CHANGELOG.md for tracking changes
  - Document version upgrade process
  - _Requirements: 11.1, 11.2, 11.4_

- [ ]* 2.4 Write property test for chart version specification
  - **Property 13: Chart version specification**
  - **Validates: Requirements 11.2**

- [ ] 3. Enhance Software Template with complete workflow
  - Update template.yaml with all required parameters
  - Add environment selection (dev/staging/prod)
  - Implement chart version parameter
  - Add validation for all inputs
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 13.1, 13.2_

- [ ] 3.1 Update template parameters
  - Add environment selection parameter
  - Add chartVersion parameter with validation
  - Add owner/team selection
  - Implement conditional parameters based on environment
  - _Requirements: 1.2, 13.1, 13.2_

- [ ] 3.2 Implement template form validation
  - Add pattern validation for name (kebab-case)
  - Add namespace validation (Kubernetes naming rules)
  - Add image repository format validation
  - Add replica count range validation (1-10)
  - _Requirements: 1.3, 1.4_

- [ ]* 3.3 Write property test for template form validation
  - **Property 1: Template form validation**
  - **Validates: Requirements 1.3**

- [ ] 4. Create CI/CD workflow template
  - Create GitHub Actions workflow for build and deploy
  - Implement linting and testing steps
  - Add Docker image build and push
  - Implement GitOps repository update
  - _Requirements: 2.3, 5.1, 5.2, 5.3, 5.4, 5.5, 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 4.1 Create GitHub Actions workflow file
  - Create `.github/workflows/ci.yaml` template
  - Add triggers for push and pull_request events
  - Configure job to run on ubuntu-latest
  - Add checkout step
  - _Requirements: 2.3, 5.1_

- [ ] 4.2 Implement code quality checks
  - Add linting step (ESLint, Prettier, or language-specific)
  - Add unit test execution step
  - Configure to fail pipeline if checks fail
  - Add test coverage reporting
  - _Requirements: 12.1, 12.2, 12.3_

- [ ] 4.3 Implement Docker image build and push
  - Add Docker build step with proper tagging (commit SHA + latest)
  - Add Docker login step with registry credentials
  - Add Docker push step to registry
  - Add image scanning step for vulnerabilities
  - _Requirements: 5.2, 5.3, 5.4, 12.5_

- [ ]* 4.4 Write property test for CI validation ordering
  - **Property 14: CI validation ordering**
  - **Validates: Requirements 12.1, 12.2, 12.3, 12.4**

- [ ] 5. Implement GitOps update automation
  - Create script to update values.yaml with new image tag
  - Implement git operations (clone, commit, push)
  - Add error handling and retry logic
  - Integrate script into CI workflow
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 5.1 Create GitOps update script
  - Create `scripts/update-gitops.sh` script
  - Implement yq commands to update image.tag in values.yaml
  - Add git clone, commit, and push operations
  - Add descriptive commit message with app name and tag
  - _Requirements: 6.1, 6.2, 6.3_

- [ ] 5.2 Add GitOps update step to CI workflow
  - Add step to workflow that calls update-gitops.sh
  - Pass required parameters (repo URL, app name, environment, tag)
  - Configure GitHub token for GitOps repo access
  - Add error handling and logging
  - _Requirements: 6.1, 6.4_

- [ ]* 5.3 Write property test for image tag update propagation
  - **Property 6: Image tag update propagation**
  - **Validates: Requirements 6.1, 6.2, 6.3**

- [ ] 6. Update template to generate complete repository structure
  - Add CI/CD workflow to template content
  - Add proper README with instructions
  - Add .gitignore file
  - Ensure catalog-info.yaml has all required annotations
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 6.1 Add CI/CD workflow to template content
  - Copy workflow template to `examples/argocd-template/content/.github/workflows/`
  - Parameterize workflow with template variables
  - Include GitOps update script in template
  - _Requirements: 2.3_

- [ ] 6.2 Enhance catalog-info.yaml template
  - Add all required ArgoCD annotations (app-name, app-namespace, instance-name)
  - Add kubernetes-id annotation
  - Add links section with ArgoCD and production URLs
  - Add proper tags and metadata
  - _Requirements: 2.2, 9.2, 9.3_

- [ ] 6.3 Create comprehensive README template
  - Add project description and setup instructions
  - Document CI/CD pipeline
  - Add deployment instructions
  - Include troubleshooting section
  - _Requirements: 2.4_

- [ ]* 6.4 Write property test for repository structure completeness
  - **Property 2: Repository structure completeness**
  - **Validates: Requirements 2.2, 2.3, 2.4**

- [ ] 7. Update GitOps values generation
  - Update values.yaml template to reference transversal chart
  - Add environment-specific values
  - Implement proper directory structure (values/{env}/{app}/)
  - Update ArgoCD Application manifest to use chart
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 13.2, 13.5_

- [ ] 7.1 Update values.yaml template
  - Reference transversal chart in values
  - Include all required fields (name, namespace, image, tag, replicas)
  - Add environment-specific resource limits
  - Add ingress configuration based on environment
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 7.2 Update ArgoCD Application manifest template
  - Update source.path to point to transversal chart
  - Add helm.valueFiles pointing to environment-specific values
  - Specify chart version explicitly
  - Configure proper syncPolicy with automated sync
  - _Requirements: 3.5, 11.2_

- [ ] 7.3 Implement environment-specific directory structure
  - Create values/{environment}/{app-name}/ structure
  - Add environment-specific defaults (dev, staging, prod)
  - Configure different resource limits per environment
  - Add production approval requirements
  - _Requirements: 13.2, 13.5_

- [ ]* 7.4 Write property test for values file completeness
  - **Property 3: Values file completeness**
  - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**

- [ ]* 7.5 Write property test for ArgoCD Application manifest validity
  - **Property 4: ArgoCD Application manifest validity**
  - **Validates: Requirements 3.5**

- [ ]* 7.6 Write property test for environment-specific configuration
  - **Property 15: Environment-specific configuration**
  - **Validates: Requirements 13.2, 13.5**

- [ ] 8. Enhance template actions for GitOps workflow
  - Update publish:github:pull-request action configuration
  - Add proper PR description with all details
  - Implement notification mechanism
  - Add catalog registration step
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 9.1, 9.3, 9.4, 9.5_

- [ ] 8.1 Configure GitOps PR creation
  - Update template to create PR in GitOps repo
  - Add comprehensive PR description with app details
  - Include links to app repository
  - Configure proper branch naming
  - _Requirements: 4.2, 4.3_

- [ ] 8.2 Implement catalog registration
  - Add catalog:register action to template
  - Configure repoContentsUrl and catalogInfoPath
  - Verify component appears in catalog after registration
  - _Requirements: 9.1, 9.3, 9.4, 9.5_

- [ ]* 8.3 Write property test for GitOps Pull Request creation
  - **Property 5: GitOps Pull Request creation**
  - **Validates: Requirements 4.2, 4.3, 4.4**

- [ ]* 8.4 Write property test for catalog registration completeness
  - **Property 11: Catalog registration completeness**
  - **Validates: Requirements 9.1, 9.3, 9.4, 9.5**

- [ ] 9. Create template output summary page
  - Configure output links section
  - Add links to app repo, GitOps PR, and catalog entity
  - Add next steps instructions
  - Format output for clarity
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ] 9.1 Configure template output section
  - Add links to app repository, GitOps PR, catalog entity
  - Add text section with next steps instructions
  - Include ArgoCD application link
  - Format output with clear sections
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [ ]* 9.2 Write property test for summary page completeness
  - **Property 12: Summary page completeness**
  - **Validates: Requirements 10.1, 10.2, 10.3, 10.4, 10.5**

- [ ] 10. Set up testing infrastructure
  - Install fast-check for property-based testing
  - Create test utilities and helpers
  - Set up test environment configuration
  - Configure test scripts in package.json
  - _Requirements: All testing requirements_

- [ ] 10.1 Install testing dependencies
  - Install fast-check package
  - Install additional testing utilities (yq, git mocks)
  - Configure TypeScript for tests
  - _Requirements: All testing requirements_

- [ ] 10.2 Create test utilities
  - Create mock GitHub API client
  - Create mock GitOps repository
  - Create test data generators
  - Create assertion helpers
  - _Requirements: All testing requirements_

- [ ]* 10.3 Write integration tests for end-to-end flow
  - Test complete template execution flow
  - Test CI pipeline execution
  - Test ArgoCD sync detection
  - Test Backstage status display
  - _Requirements: All requirements_

- [ ] 11. Documentation and examples
  - Create comprehensive README for the template
  - Document setup and configuration steps
  - Add troubleshooting guide
  - Create example applications
  - _Requirements: All requirements_

- [ ] 11.1 Create template documentation
  - Document all template parameters
  - Add usage examples
  - Document prerequisites (ArgoCD, GitOps repo, etc.)
  - Add architecture diagrams
  - _Requirements: All requirements_

- [ ] 11.2 Create setup guide
  - Document ArgoCD installation and configuration
  - Document GitOps repository setup
  - Document Helm chart deployment
  - Document Backstage configuration
  - _Requirements: All requirements_

- [ ] 12. Final checkpoint - Ensure all tests pass
  - Run all property-based tests
  - Run all integration tests
  - Verify template execution works end-to-end
  - Ask the user if questions arise
  - _Requirements: All requirements_
