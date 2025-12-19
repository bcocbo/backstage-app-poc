# ArgoCD Integration Setup Guide

## Overview

This guide explains how to configure ArgoCD integration with Backstage to display deployment status and history for your applications.

## Prerequisites

- ArgoCD installed and running in your Kubernetes cluster
- Access to ArgoCD UI and API
- ArgoCD authentication token or username/password

## Step 1: Get ArgoCD Authentication Token

### Option A: Using ArgoCD CLI (Recommended)

```bash
# Login to ArgoCD
argocd login <ARGOCD_SERVER> --username admin

# Generate a token (valid for 1 year)
argocd account generate-token --account admin --expires-in 8760h
```

### Option B: Using ArgoCD UI

1. Login to ArgoCD UI
2. Go to **Settings** → **Accounts**
3. Select your account (e.g., `admin`)
4. Click **Generate New Token**
5. Set expiration time and copy the token

### Option C: Using Kubernetes Secret

```bash
# Get the admin password from Kubernetes secret
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Step 2: Configure Environment Variables

Update your `.env` file with ArgoCD credentials:

```bash
# ArgoCD Configuration
ARGOCD_URL=https://your-argocd-instance.com
ARGOCD_AUTH_TOKEN=your-token-here

# OR use username/password (less secure)
# ARGOCD_USERNAME=admin
# ARGOCD_PASSWORD=your-password
```

### Example for Local ArgoCD

If running ArgoCD locally with port-forward:

```bash
# Port forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# In .env
ARGOCD_URL=http://localhost:8080
ARGOCD_AUTH_TOKEN=your-token-here
```

## Step 3: Verify Configuration

**IMPORTANT NOTE**: The Roadie ArgoCD backend plugin is not compatible with the new Backstage backend system. The frontend plugin works standalone by connecting directly to the ArgoCD API. This is actually simpler and doesn't require backend configuration!

The ArgoCD configuration is already added to `app-config.yaml`:

```yaml
argocd:
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argoInstance1
          url: ${ARGOCD_URL}
          token: ${ARGOCD_AUTH_TOKEN}
  waitCycles: 25
```

### Multiple ArgoCD Instances

If you have multiple ArgoCD instances (e.g., dev, staging, prod):

```yaml
argocd:
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: dev-argocd
          url: https://argocd-dev.example.com
          token: ${ARGOCD_DEV_TOKEN}
        - name: prod-argocd
          url: https://argocd-prod.example.com
          token: ${ARGOCD_PROD_TOKEN}
```

## Step 4: Add Annotations to catalog-info.yaml

Your applications need ArgoCD annotations in their `catalog-info.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-app
  annotations:
    # Required: ArgoCD application name
    argocd/app-name: my-app
    
    # Optional: ArgoCD namespace (defaults to 'argocd')
    argocd/app-namespace: argocd
    
    # Optional: Specific ArgoCD instance (if multiple)
    argocd/instance-name: argoInstance1
    
    # Optional: Kubernetes annotations
    backstage.io/kubernetes-id: my-app
```

**Note**: The template already includes these annotations automatically!

## Step 5: Restart Backstage

```bash
# Stop Backstage if running
# Then start with environment variables
./start-with-env.sh

# OR
yarn start
```

## Step 6: Verify Integration

1. **Check Backend Logs**
   - Look for ArgoCD plugin initialization messages
   - Verify no authentication errors

2. **Open an Application in Catalog**
   - Navigate to a component with ArgoCD annotations
   - You should see:
     - ArgoCD card in the Overview tab
     - ArgoCD tab with detailed information
     - Sync status and health status

3. **Expected Information**
   - **Sync Status**: Synced, OutOfSync, Unknown
   - **Health Status**: Healthy, Progressing, Degraded, Suspended, Missing
   - **Last Sync**: Timestamp of last synchronization
   - **Revision**: Git commit SHA
   - **History**: Previous deployments

## Troubleshooting

### Issue: "No ArgoCD applications found"

**Causes:**
- Application name doesn't match ArgoCD application
- Wrong namespace in annotation
- ArgoCD application doesn't exist yet

**Solution:**
```bash
# List ArgoCD applications
argocd app list

# Check if your app exists
argocd app get <app-name>

# Verify annotations match
```

### Issue: "Authentication failed"

**Causes:**
- Invalid or expired token
- Wrong ArgoCD URL
- Network connectivity issues

**Solution:**
```bash
# Test ArgoCD API directly
curl -k -H "Authorization: Bearer $ARGOCD_AUTH_TOKEN" \
  $ARGOCD_URL/api/v1/applications

# Should return JSON with applications list
```

### Issue: "ArgoCD tab not showing"

**Causes:**
- Missing annotations in catalog-info.yaml
- ArgoCD plugin not loaded
- Application not registered in catalog

**Solution:**
1. Check catalog-info.yaml has `argocd/app-name` annotation
2. Verify backend logs for ArgoCD plugin
3. Re-register component in catalog

### Issue: "Certificate errors (HTTPS)"

**Solution:**
```yaml
# In app-config.yaml, add:
argocd:
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argoInstance1
          url: ${ARGOCD_URL}
          token: ${ARGOCD_AUTH_TOKEN}
          # Skip TLS verification (not recommended for production)
          skipTLSVerify: true
```

## ArgoCD Application Naming Convention

For consistency, use the same name across:

1. **Backstage Component**: `metadata.name` in catalog-info.yaml
2. **ArgoCD Application**: Application name in ArgoCD
3. **Kubernetes Resources**: Labels and selectors
4. **GitOps Values**: Directory name in gitops-apps repo

Example:
```
Component Name: my-service
ArgoCD App: my-service
GitOps Path: values/dev/my-service/
Kubernetes Namespace: dev
```

## Security Best Practices

### 1. Use Service Accounts

Create a dedicated ArgoCD account for Backstage:

```bash
# Create account
argocd account create backstage-readonly

# Generate token
argocd account generate-token --account backstage-readonly
```

### 2. Limit Permissions

Create RBAC policy for read-only access:

```yaml
# argocd-rbac-cm ConfigMap
policy.csv: |
  p, role:backstage-readonly, applications, get, */*, allow
  p, role:backstage-readonly, applications, list, */*, allow
  g, backstage-readonly, role:backstage-readonly
```

### 3. Rotate Tokens Regularly

```bash
# Generate new token with expiration
argocd account generate-token --account backstage-readonly --expires-in 720h

# Update .env with new token
# Restart Backstage
```

### 4. Use Kubernetes Secrets

For production, store credentials in Kubernetes secrets:

```bash
# Create secret
kubectl create secret generic argocd-backstage-creds \
  --from-literal=url=https://argocd.example.com \
  --from-literal=token=your-token \
  -n backstage

# Reference in deployment
env:
  - name: ARGOCD_URL
    valueFrom:
      secretKeyRef:
        name: argocd-backstage-creds
        key: url
  - name: ARGOCD_AUTH_TOKEN
    valueFrom:
      secretKeyRef:
        name: argocd-backstage-creds
        key: token
```

## Features Available

### Overview Card
- Current sync status
- Health status
- Last sync time
- Quick link to ArgoCD UI

### History Card
- Deployment history
- Git revisions
- Sync results
- Timestamps

### ArgoCD Tab
- Detailed application information
- Resource tree
- Sync policy
- Auto-sync status
- Prune settings

## Next Steps

1. **Create Applications**: Use the Backstage template to create new applications
2. **Monitor Deployments**: Check ArgoCD status in Backstage catalog
3. **Set Up Notifications**: Configure ArgoCD notifications for deployment events
4. **Add Metrics**: Integrate Prometheus metrics for deployment frequency

## Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Backstage ArgoCD Plugin](https://github.com/RoadieHQ/roadie-backstage-plugins/tree/main/plugins/frontend/backstage-plugin-argo-cd)
- [GitOps Principles](https://opengitops.dev/)

## Support

If you encounter issues:

1. Check backend logs: `yarn start` output
2. Verify ArgoCD API access: `curl` test
3. Check annotations in catalog-info.yaml
4. Review this guide's troubleshooting section
5. Check ArgoCD application exists: `argocd app get <name>`

---

**Status**: ✅ ArgoCD integration configured and ready to use!
