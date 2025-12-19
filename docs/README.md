# 📚 Documentación Completa - Backstage GitOps Platform

## 🎯 Acceso Rápido

### Documentación HTML Consolidada
- **[📄 Documentación Completa (HTML)](documentacion-completa.html)** - Toda la documentación en una sola página

### Documentación por Secciones

#### 🏠 Inicio y Resumen
- [README Principal](../README.md)
- [Resumen Final](../RESUMEN_FINAL.md)
- [Resumen de Sesión](../SESSION_SUMMARY.md)
- [Implementación Summary](../IMPLEMENTATION_SUMMARY.md)

#### 🏗️ Arquitectura
- [Diagramas de Arquitectura](../ARQUITECTURA_DIAGRAMA.md)
- [Diseño del Sistema](../.kiro/specs/backstage-argocd-gitops-flow/design.md)
- [Requisitos](../.kiro/specs/backstage-argocd-gitops-flow/requirements.md)

#### ⚙️ Setup y Configuración
- [Setup de ArgoCD](../ARGOCD_SETUP.md)
- [Setup de GitOps](../GITOPS_SETUP.md)
- [Cómo Iniciar Backstage](../COMO_INICIAR.md)
- [Nota sobre Plugin de ArgoCD](../ARGOCD_PLUGIN_NOTE.md)

#### 👨‍💻 Desarrollo
- [Quick Start para Desarrolladores](../DEVELOPER_QUICK_START.md)
- [Guía de Testing](../TEST_TEMPLATE.md)
- [Referencia Rápida](../QUICK_REFERENCE.md)

#### 🔧 Operaciones
- [Actualización del Chart Transversal](../ACTUALIZACION_CHART_TRANSVERSAL.md)
- [Tareas de Implementación](../.kiro/specs/backstage-argocd-gitops-flow/tasks.md)

#### 🔐 Seguridad
- [Seguridad Crítica - Tokens](../SECURITY_CRITICAL.md)
- [Solución de Problemas con Tokens](../SOLUCION_TOKEN.md)
- [Fix GitHub Token](../FIX_GITHUB_TOKEN.md)

#### ✅ Producción
- [Checklist de Producción](../PRODUCTION_CHECKLIST.md)

## 🚀 Cómo Usar Esta Documentación

### Para Desarrolladores
1. Empieza con [Quick Start](../DEVELOPER_QUICK_START.md)
2. Revisa [Referencia Rápida](../QUICK_REFERENCE.md)
3. Consulta [Troubleshooting](../COMO_INICIAR.md) si hay problemas

### Para Platform Team
1. Lee [Resumen Final](../RESUMEN_FINAL.md)
2. Revisa [Arquitectura](../ARQUITECTURA_DIAGRAMA.md)
3. Implementa siguiendo [Setup de ArgoCD](../ARGOCD_SETUP.md) y [Setup de GitOps](../GITOPS_SETUP.md)
4. Usa [Checklist de Producción](../PRODUCTION_CHECKLIST.md)

### Para Operaciones
1. Consulta [Actualización del Chart](../ACTUALIZACION_CHART_TRANSVERSAL.md)
2. Revisa [Seguridad](../SECURITY_CRITICAL.md)
3. Usa [Referencia Rápida](../QUICK_REFERENCE.md) para comandos comunes

## 📊 Estado del Proyecto

| Componente | Estado | Notas |
|------------|--------|-------|
| Backstage | ✅ Funcionando | Puerto 3000 |
| Backend | ✅ Funcionando | Puerto 7007 |
| PostgreSQL | ✅ Conectado | Usuario: mariague |
| ArgoCD Plugin | ✅ Integrado | Solo frontend (backend incompatible) |
| Templates | ✅ Funcionando | 2 tipos de apps, 5 lenguajes |
| CI/CD | ✅ Configurado | GitHub Actions + ECR |
| GitOps Repo | ✅ Creado | github.com/bcocbo/gitops-apps |
| Helm Chart | ✅ Creado | github.com/bcocbo/eks_baseline_chart_Helm |
| Documentación | ✅ Completa | 15+ archivos |

## 🎓 Recursos Adicionales

### Externos
- [Backstage Documentation](https://backstage.io/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://opengitops.dev/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)

### Internos
- [Ejemplos de Templates](../examples/)
- [Configuración de Backstage](../app-config.yaml)
- [Scripts Helper](../) - `start-with-env.sh`, `restart-backstage.sh`

## 📞 Soporte

Si encuentras problemas:
1. Revisa [Cómo Iniciar](../COMO_INICIAR.md)
2. Consulta [Seguridad Crítica](../SECURITY_CRITICAL.md) para temas de tokens
3. Lee [Nota sobre Plugin ArgoCD](../ARGOCD_PLUGIN_NOTE.md) para el error "Failed to fetch"
4. Revisa logs de Backstage en la terminal

---

**Última Actualización**: Diciembre 6, 2025  
**Versión**: 1.0.0  
**Estado**: ✅ Implementación Completa y Funcional
