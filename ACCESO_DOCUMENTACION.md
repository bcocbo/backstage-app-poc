# 📚 Acceso a la Documentación

## 🌟 Portal Principal

### Opción 1: Portal Visual Interactivo (Recomendado)

```bash
open docs/index.html
```

**Características**:
- 🎨 Interfaz visual moderna
- 📊 Estado del sistema en tiempo real
- 🔗 Acceso rápido a todas las secciones
- 📱 Diseño responsive
- ⚡ Navegación por tarjetas

### Opción 2: Documentación Completa en HTML

```bash
open docs/documentacion-completa.html
```

**Características**:
- 📄 Todo en una sola página
- 🎨 Markdown renderizado con estilos
- 📊 Diagramas Mermaid interactivos
- 💻 Código con syntax highlighting
- 🔗 Navegación con scroll suave
- 📑 Tabla de contenidos sticky

### Opción 3: Archivos Markdown Individuales

Todos los archivos `.md` en la raíz del proyecto:

```bash
# Ver lista completa
ls -1 *.md

# Abrir en tu editor favorito
code README.md
vim GUIA_CREAR_SCAFFOLDER.md
```

## 📖 Guías Disponibles

### Para Empezar

| Documento | Descripción | Comando |
|-----------|-------------|---------|
| `README.md` | Punto de entrada principal | `open README.md` |
| `COMO_INICIAR.md` | Cómo iniciar Backstage | `open COMO_INICIAR.md` |
| `DEVELOPER_QUICK_START.md` | Quick start para desarrolladores | `open DEVELOPER_QUICK_START.md` |
| `QUICK_REFERENCE.md` | Referencia rápida de comandos | `open QUICK_REFERENCE.md` |

### Arquitectura y Diseño

| Documento | Descripción | Comando |
|-----------|-------------|---------|
| `ARQUITECTURA_DIAGRAMA.md` | Diagramas completos del sistema | `open ARQUITECTURA_DIAGRAMA.md` |
| `IMPLEMENTATION_SUMMARY.md` | Resumen de implementación | `open IMPLEMENTATION_SUMMARY.md` |
| `RESUMEN_FINAL.md` | Resumen ejecutivo | `open RESUMEN_FINAL.md` |

### Setup y Configuración

| Documento | Descripción | Comando |
|-----------|-------------|---------|
| `ARGOCD_SETUP.md` | Configuración de ArgoCD | `open ARGOCD_SETUP.md` |
| `GITOPS_SETUP.md` | Configuración de GitOps | `open GITOPS_SETUP.md` |
| `SOLUCION_TOKEN.md` | Solución de problemas con tokens | `open SOLUCION_TOKEN.md` |

### Guías Avanzadas ⭐ NUEVO

| Documento | Descripción | Comando |
|-----------|-------------|---------|
| `GUIA_AGREGAR_PLUGIN.md` | Cómo agregar plugins a Backstage | `open GUIA_AGREGAR_PLUGIN.md` |
| `GUIA_CREAR_SCAFFOLDER.md` | Cómo crear scaffolder templates | `open GUIA_CREAR_SCAFFOLDER.md` |

### Operaciones

| Documento | Descripción | Comando |
|-----------|-------------|---------|
| `ACTUALIZACION_CHART_TRANSVERSAL.md` | Actualizar el chart Helm | `open ACTUALIZACION_CHART_TRANSVERSAL.md` |
| `PRODUCTION_CHECKLIST.md` | Checklist para producción | `open PRODUCTION_CHECKLIST.md` |

### Seguridad

| Documento | Descripción | Comando |
|-----------|-------------|---------|
| `SECURITY_CRITICAL.md` | Seguridad crítica | `open SECURITY_CRITICAL.md` |
| `FIX_GITHUB_TOKEN.md` | Fix de GitHub token | `open FIX_GITHUB_TOKEN.md` |

### Notas Técnicas

| Documento | Descripción | Comando |
|-----------|-------------|---------|
| `ARGOCD_PLUGIN_NOTE.md` | Nota sobre plugin de ArgoCD | `open ARGOCD_PLUGIN_NOTE.md` |
| `SESSION_SUMMARY.md` | Resumen de sesión | `open SESSION_SUMMARY.md` |
| `TEST_TEMPLATE.md` | Guía de testing | `open TEST_TEMPLATE.md` |

## 🔄 Regenerar Documentación

Si haces cambios en los archivos `.md`, regenera el HTML:

```bash
# Regenerar documentación completa
python3 generate-docs.py

# Verificar resultado
open docs/documentacion-completa.html
```

## 🎯 Acceso Rápido por Rol

### 👨‍💻 Desarrollador

**Quiero crear mi primera aplicación**:
1. `open DEVELOPER_QUICK_START.md`
2. `open docs/index.html` → Sección "Desarrollo"

**Quiero crear un template personalizado**:
1. `open GUIA_CREAR_SCAFFOLDER.md`
2. Ver ejemplos en `examples/argocd-template/`

**Tengo un problema**:
1. `open COMO_INICIAR.md`
2. `open QUICK_REFERENCE.md`

### 🔧 Platform Engineer

**Quiero configurar el sistema**:
1. `open ARGOCD_SETUP.md`
2. `open GITOPS_SETUP.md`
3. `open PRODUCTION_CHECKLIST.md`

**Quiero agregar funcionalidad**:
1. `open GUIA_AGREGAR_PLUGIN.md`
2. `open GUIA_CREAR_SCAFFOLDER.md`

**Quiero actualizar el chart**:
1. `open ACTUALIZACION_CHART_TRANSVERSAL.md`

### 👔 Manager/Arquitecto

**Quiero entender la arquitectura**:
1. `open docs/documentacion-completa.html` → Sección "Arquitectura"
2. `open ARQUITECTURA_DIAGRAMA.md`
3. `open IMPLEMENTATION_SUMMARY.md`

**Quiero ver el estado del proyecto**:
1. `open RESUMEN_FINAL.md`
2. `open docs/index.html` → Ver "Estado del Sistema"

**Quiero preparar para producción**:
1. `open PRODUCTION_CHECKLIST.md`
2. `open SECURITY_CRITICAL.md`

## 📊 Estructura de la Documentación

```
backstage-app-poc-main/
│
├── docs/                              # Documentación HTML
│   ├── index.html                     # Portal visual
│   └── documentacion-completa.html    # Documentación completa
│
├── *.md                               # Guías en Markdown
│   ├── README.md                      # Punto de entrada
│   ├── GUIA_AGREGAR_PLUGIN.md        # ⭐ NUEVO
│   ├── GUIA_CREAR_SCAFFOLDER.md      # ⭐ NUEVO
│   └── ...                            # Otras guías
│
├── .kiro/specs/                       # Especificaciones técnicas
│   └── backstage-argocd-gitops-flow/
│       ├── requirements.md
│       ├── design.md
│       └── tasks.md
│
└── examples/                          # Ejemplos y templates
    └── argocd-template/
        ├── template.yaml
        └── content/
```

## 🔍 Búsqueda de Información

### Por Tema

```bash
# Buscar en toda la documentación
grep -r "ArgoCD" *.md

# Buscar en archivos específicos
grep "template" GUIA_CREAR_SCAFFOLDER.md

# Buscar con contexto
grep -A 5 -B 5 "plugin" GUIA_AGREGAR_PLUGIN.md
```

### Por Palabra Clave

| Busco información sobre... | Ver documento |
|---------------------------|---------------|
| Crear aplicación | `DEVELOPER_QUICK_START.md` |
| Crear template | `GUIA_CREAR_SCAFFOLDER.md` |
| Agregar plugin | `GUIA_AGREGAR_PLUGIN.md` |
| Configurar ArgoCD | `ARGOCD_SETUP.md` |
| Configurar GitOps | `GITOPS_SETUP.md` |
| Problemas de inicio | `COMO_INICIAR.md` |
| Tokens de GitHub | `SOLUCION_TOKEN.md` |
| Actualizar chart | `ACTUALIZACION_CHART_TRANSVERSAL.md` |
| Arquitectura | `ARQUITECTURA_DIAGRAMA.md` |
| Producción | `PRODUCTION_CHECKLIST.md` |
| Seguridad | `SECURITY_CRITICAL.md` |
| Comandos rápidos | `QUICK_REFERENCE.md` |

## 💡 Tips

### Navegación Eficiente

1. **Usa el portal visual** para explorar:
   ```bash
   open docs/index.html
   ```

2. **Usa la documentación completa** para buscar:
   ```bash
   open docs/documentacion-completa.html
   # Luego usa Cmd+F (Mac) o Ctrl+F (Windows/Linux)
   ```

3. **Usa tu editor** para editar:
   ```bash
   code .  # VS Code
   vim .   # Vim
   ```

### Marcadores Útiles

Agrega estos a tu navegador:

- `file:///path/to/backstage-app-poc-main/docs/index.html`
- `file:///path/to/backstage-app-poc-main/docs/documentacion-completa.html`
- `http://localhost:3000` (Backstage)

### Atajos de Teclado

En la documentación HTML:

- `Cmd/Ctrl + F`: Buscar en la página
- `Cmd/Ctrl + Click`: Abrir link en nueva pestaña
- `Scroll`: Navegación suave automática

## 🆘 Ayuda

### No encuentro lo que busco

1. Abre el portal visual: `open docs/index.html`
2. Usa la búsqueda del navegador: `Cmd/Ctrl + F`
3. Revisa la tabla de contenidos arriba

### Los diagramas no se ven

1. Abre en un navegador moderno (Chrome, Firefox, Safari, Edge)
2. Verifica que JavaScript esté habilitado
3. Regenera la documentación: `python3 generate-docs.py`

### Quiero contribuir

1. Edita o crea archivos `.md`
2. Agrega a `generate-docs.py` si es necesario
3. Regenera: `python3 generate-docs.py`
4. Verifica: `open docs/documentacion-completa.html`

## 📞 Soporte

- **Documentación**: Este archivo y el portal visual
- **Issues**: Crea un issue en GitHub
- **Platform Team**: Contacta al equipo de plataforma

---

**Última actualización**: 6 de Diciembre, 2025  
**Versión**: 1.1.0  
**Estado**: ✅ Documentación completa y actualizada
