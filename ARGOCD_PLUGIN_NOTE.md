# ArgoCD Plugin Configuration Note

## ⚠️ Backend Plugin Compatibility Issue

### Problem Discovered

The `@roadiehq/backstage-plugin-argo-cd-backend` plugin is **not compatible** with the new Backstage backend system (backend-defaults).

### Error Symptoms

- Backend fails to start
- Port 7007 not listening
- Frontend shows "TypeError: Failed to fetch"
- No API responses from backend

### Solution Implemented

**The backend plugin has been disabled.** The frontend plugin works perfectly fine without it!

### How It Works Now

The ArgoCD frontend plugin (`@roadiehq/backstage-plugin-argo-cd`) connects **directly** to the ArgoCD API:

```
Backstage Frontend → ArgoCD API (direct connection)
```

Instead of:
```
Backstage Frontend → Backstage Backend → ArgoCD API (not working)
```

### Configuration

The frontend plugin uses the configuration in `app-config.yaml`:

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

### Environment Variables Required

```bash
# In .env file
ARGOCD_URL=https://your-argocd-instance.com
ARGOCD_USERNAME=admin
ARGOCD_PASSWORD=your-password

# OR use token (if ArgoCD supports it)
# ARGOCD_AUTH_TOKEN=your-token
```

### What Still Works

✅ **Everything works!** The frontend plugin provides:
- ArgoCD overview card in entity pages
- ArgoCD dedicated tab with full details
- Sync status monitoring
- Deployment history
- Health status
- Direct links to ArgoCD UI

### What Changed

❌ Backend plugin removed from `packages/backend/src/index.ts`
✅ Frontend plugin still active in `packages/app`
✅ Direct API connection from browser to ArgoCD
✅ Simpler architecture, fewer moving parts

### Benefits of This Approach

1. **Simpler**: No backend proxy needed
2. **Faster**: Direct connection, no intermediary
3. **Compatible**: Works with new Backstage backend system
4. **Secure**: Uses ArgoCD's own authentication

### CORS Considerations

If you encounter CORS errors, you may need to configure ArgoCD to allow requests from your Backstage domain:

```yaml
# In ArgoCD ConfigMap (argocd-cm)
data:
  # Allow Backstage origin
  cors.allowed.origins: |
    - http://localhost:3000
    - https://backstage.your-domain.com
```

Or use ArgoCD's built-in proxy if available.

### Alternative: Use Backstage Proxy

If direct connection doesn't work due to CORS or network policies, you can use Backstage's built-in proxy:

```yaml
# In app-config.yaml
proxy:
  endpoints:
    '/argocd/api':
      target: ${ARGOCD_URL}/api/v1
      changeOrigin: true
      headers:
        Authorization: 'Bearer ${ARGOCD_AUTH_TOKEN}'
```

Then configure the plugin to use the proxy:

```yaml
argocd:
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argoInstance1
          url: /argocd/api  # Use proxy endpoint
```

### Testing

After restarting Backstage:

1. Backend should start successfully on port 7007
2. Frontend should load on port 3000
3. Navigate to a component with ArgoCD annotations
4. ArgoCD card should appear (if ArgoCD is configured)
5. ArgoCD tab should show deployment details

### Troubleshooting

**Backend not starting?**
- Check `packages/backend/src/index.ts` - ArgoCD backend plugin should be commented out
- Restart Backstage: `./restart-backstage.sh`

**ArgoCD card not showing?**
- Check ArgoCD credentials in `.env`
- Verify ArgoCD URL is accessible from your browser
- Check browser console for CORS errors
- Verify component has `argocd/app-name` annotation

**Authentication errors?**
- Verify ArgoCD username/password are correct
- Try using token authentication instead
- Check ArgoCD API is accessible: `curl -k $ARGOCD_URL/api/version`

### References

- [Roadie ArgoCD Plugin Docs](https://github.com/RoadieHQ/roadie-backstage-plugins/tree/main/plugins/frontend/backstage-plugin-argo-cd)
- [Backstage Proxy Configuration](https://backstage.io/docs/plugins/proxying)
- [ArgoCD API Documentation](https://argo-cd.readthedocs.io/en/stable/developer-guide/api-docs/)

---

**Status**: ✅ Working with frontend-only plugin
**Last Updated**: December 6, 2025
