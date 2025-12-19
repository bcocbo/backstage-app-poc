# Quick Reference Card

## 🚀 Common Commands

### Start Backstage
```bash
./start-with-env.sh
# OR
yarn start
```

### Restart Backstage
```bash
./restart-backstage.sh
```

### Check Logs
```bash
# Backstage logs are in the terminal where you ran yarn start
# Look for errors related to ArgoCD, GitHub, or PostgreSQL
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `.env` | Environment variables (tokens, credentials) |
| `app-config.yaml` | Backstage configuration |
| `examples/argocd-template/template.yaml` | Software template definition |
| `packages/backend/src/index.ts` | Backend plugins |
| `packages/app/src/components/catalog/EntityPage.tsx` | Frontend UI |

## 🔑 Environment Variables

```bash
# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# GitHub
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx

# ArgoCD
ARGOCD_URL=https://argocd.example.com
ARGOCD_AUTH_TOKEN=your-token-here
```

## 📝 Creating an Application

1. Open http://localhost:3000
2. Click **Create**
3. Select **ArgoCD - Aplicación Hola Mundo**
4. Fill form:
   - Name: `my-app`
   - Environment: `dev`
   - Type: `custom` or `prebuilt`
   - Language: `nodejs` (if custom)
5. Click **Create**
6. Approve GitOps PR
7. Wait for ArgoCD sync

## 🔍 Checking Application Status

### In Backstage
```
Catalog → Your App → Overview Tab → ArgoCD Card
Catalog → Your App → ArgoCD Tab → Detailed Info
Catalog → Your App → Kubernetes Tab → Pods
```

### In ArgoCD CLI
```bash
argocd app list
argocd app get my-app
argocd app sync my-app
argocd app history my-app
```

### In Kubernetes
```bash
kubectl get pods -n dev -l app=my-app
kubectl logs -n dev -l app=my-app
kubectl describe pod -n dev <pod-name>
```

## 🔄 Updating an Application

### Code Changes (Custom Apps)
```bash
git clone https://github.com/bcocbo/my-app.git
cd my-app
# Make changes
git add .
git commit -m "feat: new feature"
git push
# CI/CD runs automatically
# Approve GitOps PR
# ArgoCD syncs automatically
```

### Configuration Changes
```bash
git clone https://github.com/bcocbo/gitops-apps.git
cd gitops-apps
vim values/dev/my-app/values.yaml
# Make changes
git add .
git commit -m "chore: update config"
git push
# ArgoCD syncs automatically
```

## 🐛 Troubleshooting

### Backstage Won't Start
```bash
# Check PostgreSQL
psql -h localhost -U postgres -d postgres

# Check environment variables
cat .env

# Kill existing process
pkill -f backstage

# Start again
./start-with-env.sh
```

### GitHub Token Error
```bash
# Verify token in .env
cat .env | grep GITHUB_TOKEN

# Test token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# If expired, generate new token at:
# https://github.com/settings/tokens
```

### ArgoCD Not Showing
```bash
# Check ArgoCD credentials
cat .env | grep ARGOCD

# Test ArgoCD API
curl -k -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" \
  $ARGOCD_URL/api/v1/applications

# Check annotations in catalog-info.yaml
# Must have: argocd/app-name annotation
```

### Application Not Syncing
```bash
# Check ArgoCD application exists
argocd app get my-app

# Force sync
argocd app sync my-app

# Check sync status
argocd app wait my-app

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

## 📊 Useful URLs

| Service | URL |
|---------|-----|
| Backstage | http://localhost:3000 |
| Backstage API | http://localhost:7007 |
| ArgoCD | https://argocd.example.com |
| GitHub | https://github.com/bcocbo |
| GitOps Repo | https://github.com/bcocbo/gitops-apps |
| Helm Chart | https://github.com/bcocbo/eks_baseline_chart_Helm |

## 🔐 Getting Tokens

### GitHub Token
```
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: repo, workflow, write:packages
4. Generate and copy token
5. Add to .env: GITHUB_TOKEN=ghp_xxxxx
```

### ArgoCD Token
```bash
# Method 1: CLI
argocd login <ARGOCD_SERVER>
argocd account generate-token --account admin

# Method 2: UI
# Settings → Accounts → admin → Generate New Token

# Method 3: Kubernetes Secret
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

## 📦 Repository Structure

```
Application Repo (my-app)
├── src/                    # Source code
├── Dockerfile             # Container definition
├── .github/workflows/     # CI/CD pipeline
└── catalog-info.yaml      # Backstage metadata

GitOps Repo (gitops-apps)
├── values/
│   ├── dev/my-app/       # Dev configuration
│   ├── staging/my-app/   # Staging configuration
│   └── prod/my-app/      # Prod configuration
└── argocd/applications/  # ArgoCD app definitions
```

## 🎯 Common Tasks

### Scale Application
```bash
cd gitops-apps
vim values/dev/my-app/values.yaml
# Change: replicas: 5
git commit -am "scale: increase to 5 replicas"
git push
```

### Change Image Version
```bash
cd gitops-apps
vim values/dev/my-app/values.yaml
# Change: tag: v1.2.3
git commit -am "chore: update to v1.2.3"
git push
```

### Add Environment Variable
```bash
cd gitops-apps
vim values/dev/my-app/values.yaml
# Add under env:
#   - name: LOG_LEVEL
#     value: debug
git commit -am "config: add LOG_LEVEL"
git push
```

### Rollback Deployment
```bash
# Method 1: ArgoCD
argocd app history my-app
argocd app rollback my-app <revision-id>

# Method 2: Git
cd gitops-apps
git revert <commit-hash>
git push
```

## 📚 Documentation Quick Links

- **Getting Started**: [DEVELOPER_QUICK_START.md](DEVELOPER_QUICK_START.md)
- **ArgoCD Setup**: [ARGOCD_SETUP.md](ARGOCD_SETUP.md)
- **GitOps Setup**: [GITOPS_SETUP.md](GITOPS_SETUP.md)
- **Testing**: [TEST_TEMPLATE.md](TEST_TEMPLATE.md)
- **Architecture**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
- **Production**: [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)

## 🆘 Getting Help

1. Check documentation above
2. Review troubleshooting section
3. Check Backstage logs
4. Check ArgoCD logs
5. Contact platform team

## 💡 Tips

- Always test in `dev` environment first
- Use descriptive commit messages
- Review PRs before merging
- Monitor ArgoCD sync status
- Keep documentation updated
- Use semantic versioning for images
- Set resource limits for all apps
- Enable health checks
- Use secrets for sensitive data
- Tag resources for cost tracking

---

**Keep this handy for quick reference!**
