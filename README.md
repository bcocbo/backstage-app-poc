# Backstage GitOps Platform

Enterprise-grade GitOps platform built on Backstage with ArgoCD integration for automated Kubernetes deployments.

## 🚀 Quick Start

```bash
# Install dependencies
yarn install

# Start Backstage with environment variables
./start-with-env.sh

# OR start normally
yarn start
```

Open http://localhost:3000

**⚠️ Si tienes problemas iniciando**: Ver [COMO_INICIAR.md](COMO_INICIAR.md)

## 📚 Documentation

### 🌟 Portal de Documentación
- **[📄 Portal Visual de Documentación](docs/index.html)** - Acceso visual a toda la documentación
- **[📋 Documentación Completa (HTML)](docs/documentacion-completa.html)** - Todo en una sola página con Markdown y diagramas renderizados

Para regenerar la documentación HTML:
```bash
python3 generate-docs.py
```

### Quick Access
- **[Quick Reference Card](QUICK_REFERENCE.md)** - Common commands and tasks ⚡

### For Developers
- **[Developer Quick Start](DEVELOPER_QUICK_START.md)** - Create and deploy your first application
- **[Testing Guide](TEST_TEMPLATE.md)** - How to test the template

### For Platform Team
- **[Implementation Summary](IMPLEMENTATION_SUMMARY.md)** - Architecture and design decisions
- **[GitOps Setup](GITOPS_SETUP.md)** - Configure GitOps repositories
- **[ArgoCD Setup](ARGOCD_SETUP.md)** - Configure ArgoCD integration
- **[GitHub Token Setup](SOLUCION_TOKEN.md)** - Troubleshoot GitHub authentication
- **[🔐 Configurar Secrets de GitHub](CONFIGURAR_SECRETS_GITHUB.md)** - Configurar AWS y GitHub secrets para CI/CD

### Advanced Guides
- **[🔌 Agregar Plugin a Backstage](GUIA_AGREGAR_PLUGIN.md)** - Guía completa para agregar plugins
- **[📝 Crear Scaffolder Template](GUIA_CREAR_SCAFFOLDER.md)** - Guía paso a paso para crear templates

### Technical Documentation
- **[Requirements](.kiro/specs/backstage-argocd-gitops-flow/requirements.md)** - Detailed requirements
- **[Design](.kiro/specs/backstage-argocd-gitops-flow/design.md)** - System design
- **[Tasks](.kiro/specs/backstage-argocd-gitops-flow/tasks.md)** - Implementation tasks

## 🏗️ Architecture

```
Backstage → GitHub (App Repos) → CI/CD → ECR → GitOps Repo → ArgoCD → Kubernetes
```

### Key Components

1. **Backstage**: Developer portal and software catalog
2. **Software Templates**: Automated project scaffolding
3. **GitOps Repository**: Centralized configuration management
4. **Helm Chart**: Transversal chart for all applications
5. **ArgoCD**: Continuous deployment to Kubernetes
6. **CI/CD**: Automated build and deployment pipeline

## ✨ Features

- ✅ **Two Application Types**:
  - Custom applications with full CI/CD (Node.js, Python, Java, Go, .NET)
  - Prebuilt images (nginx, redis, etc.)
- ✅ **Multi-Environment**: dev, staging, production
- ✅ **GitOps Workflow**: Pull request-based deployments
- ✅ **ArgoCD Integration**: Real-time deployment status in Backstage
- ✅ **Automated CI/CD**: Build, test, and deploy on every commit
- ✅ **Security**: OIDC authentication, non-root containers, security contexts
- ✅ **Scalability**: Supports 100+ applications

## 🎯 Creating Your First Application

1. Click **Create** in Backstage
2. Select **ArgoCD - Aplicación Hola Mundo**
3. Fill in the form (name, environment, type)
4. Click **Create**
5. Approve the GitOps PR
6. Watch ArgoCD deploy automatically!

See [Developer Quick Start](DEVELOPER_QUICK_START.md) for detailed instructions.

## 🔧 Configuration

### Required Environment Variables

```bash
# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# GitHub
GITHUB_TOKEN=your-github-token

# ArgoCD
ARGOCD_URL=https://argocd.example.com
ARGOCD_AUTH_TOKEN=your-argocd-token
```

See `.env.example` for all available options.

### GitHub Token

The GitHub token needs write access to create repositories. See [SOLUCION_TOKEN.md](SOLUCION_TOKEN.md) for setup instructions.

### ArgoCD Integration

Configure ArgoCD credentials to see deployment status in Backstage. See [ARGOCD_SETUP.md](ARGOCD_SETUP.md) for detailed setup.

## 📦 Repositories

### Application Repositories
- Created automatically by Backstage template
- Contains application code and Dockerfile
- Includes CI/CD workflow
- Example: `https://github.com/bcocbo/my-app`

### GitOps Repository
- **URL**: `https://github.com/bcocbo/gitops-apps`
- Centralized configuration for all applications
- Environment-specific values
- ArgoCD application definitions

### Helm Chart Repository
- **URL**: `https://github.com/bcocbo/eks_baseline_chart_Helm`
- Transversal Helm chart for all applications
- Standardized Kubernetes resources
- Security best practices built-in

## 🔐 Security

- ✅ Non-root containers
- ✅ Security contexts configured
- ✅ Resource limits enforced
- ✅ OIDC for AWS authentication
- ✅ Secrets management via Kubernetes
- ✅ RBAC in ArgoCD
- ✅ Pull request-based approvals

## 🌍 Environments

### Development
- Auto-sync enabled
- Fast iteration
- No approval required

### Staging
- Auto-sync enabled
- Pre-production testing
- Approval recommended

### Production
- Auto-sync with sync window (2-6 AM)
- Manual approval required
- Prune and self-heal disabled

## 🛠️ Helper Scripts

```bash
# Start Backstage with environment variables
./start-with-env.sh

# Restart Backstage (kills existing process)
./restart-backstage.sh

# Setup PostgreSQL
./setup-postgres.sh
```

## 📊 Monitoring

### In Backstage
- **Catalog**: View all applications
- **Overview Tab**: ArgoCD sync status
- **ArgoCD Tab**: Detailed deployment info
- **Kubernetes Tab**: Pod status and logs

### In ArgoCD
- Application health and sync status
- Resource tree visualization
- Deployment history
- Sync operations

## 🐛 Troubleshooting

### Backstage Won't Start
```bash
# Check PostgreSQL
psql -h localhost -U postgres -d postgres

# Check environment variables
cat .env

# Check logs
yarn start
```

### Template Creation Fails
- Verify GitHub token has correct permissions
- Check repository doesn't already exist
- Review Backstage logs

### ArgoCD Not Showing
- Verify ArgoCD credentials in `.env`
- Check annotations in `catalog-info.yaml`
- Ensure ArgoCD application exists

See individual documentation files for detailed troubleshooting.

## 🧪 Testing

```bash
# Run all tests
yarn test

# Run specific test
yarn test <test-name>

# E2E tests
yarn test:e2e
```

See [TEST_TEMPLATE.md](TEST_TEMPLATE.md) for testing guide.

## 📈 Roadmap

- [x] Basic Backstage setup
- [x] Software template
- [x] GitOps repository structure
- [x] Helm chart
- [x] CI/CD pipeline
- [x] ArgoCD integration
- [ ] Property-based tests
- [ ] Integration tests
- [ ] Notifications
- [ ] Metrics and dashboards
- [ ] Progressive delivery (Canary, Blue/Green)
- [ ] Multi-cluster support

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📞 Support

- **Documentation**: See links above
- **Issues**: Create a GitHub issue
- **Platform Team**: Contact for assistance

## 📄 License

This project is licensed under the Apache License 2.0.

---

Built with ❤️ using [Backstage](https://backstage.io)
