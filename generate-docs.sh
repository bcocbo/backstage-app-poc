#!/bin/bash

# Script para generar documentación HTML consolidada
# Convierte todos los archivos .md en una página HTML única

OUTPUT="docs/documentacion-completa.html"

echo "🚀 Generando documentación HTML completa..."

# Crear directorio si no existe
mkdir -p docs

# Iniciar HTML
cat > "$OUTPUT" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Backstage GitOps Platform - Documentación Completa</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.0/github-markdown.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --primary: #4A90E2;
            --secondary: #FF6B35;
            --success: #28A745;
            --dark: #2C3E50;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            background: #f5f7fa;
        }
        
        .header {
            background: linear-gradient(135deg, var(--primary) 0%, #357ABD 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header h1 { font-size: 2.5rem; margin-bottom: 0.5rem; }
        .header p { font-size: 1.2rem; opacity: 0.9; }
        
        .nav {
            background: white;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            padding: 1rem 0;
        }
        
        .nav-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            gap: 1rem;
            padding: 0 2rem;
            flex-wrap: wrap;
        }
        
        .nav a {
            color: var(--dark);
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            transition: all 0.3s;
        }
        
        .nav a:hover {
            background: var(--primary);
            color: white;
        }
        
        .container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 2rem;
        }
        
        .section {
            background: white;
            border-radius: 10px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        
        .markdown-body {
            box-sizing: border-box;
            min-width: 200px;
            max-width: 980px;
            margin: 0 auto;
            padding: 45px;
        }
        
        .footer {
            background: var(--dark);
            color: white;
            text-align: center;
            padding: 2rem;
            margin-top: 3rem;
        }
        
        @media (max-width: 768px) {
            .header h1 { font-size: 1.8rem; }
            .nav-content { flex-direction: column; }
            .markdown-body { padding: 15px; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Backstage GitOps Platform</h1>
        <p>Documentación Completa - Arquitectura, Setup y Guías</p>
    </div>

    <nav class="nav">
        <div class="nav-content">
            <a href="#readme">📖 README</a>
            <a href="#resumen">📊 Resumen</a>
            <a href="#arquitectura">🏗️ Arquitectura</a>
            <a href="#setup-argocd">⚙️ Setup ArgoCD</a>
            <a href="#setup-gitops">🔄 Setup GitOps</a>
            <a href="#quick-start">🚀 Quick Start</a>
            <a href="#actualizacion-chart">📦 Actualización Chart</a>
            <a href="#seguridad">🔐 Seguridad</a>
            <a href="#troubleshooting">🐛 Troubleshooting</a>
            <a href="#produccion">✅ Producción</a>
        </div>
    </nav>

    <div class="container">
EOF

# Función para agregar sección
add_section() {
    local id=$1
    local title=$2
    local file=$3
    
    if [ -f "$file" ]; then
        echo "  📄 Agregando: $title"
        echo "<section id=\"$id\" class=\"section\">" >> "$OUTPUT"
        echo "<div class=\"markdown-body\">" >> "$OUTPUT"
        # Convertir markdown a HTML (simplificado)
        cat "$file" | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' >> "$OUTPUT"
        echo "</div>" >> "$OUTPUT"
        echo "</section>" >> "$OUTPUT"
    fi
}

# Agregar secciones
add_section "readme" "README Principal" "README.md"
add_section "resumen" "Resumen Final" "RESUMEN_FINAL.md"
add_section "arquitectura" "Arquitectura" "ARQUITECTURA_DIAGRAMA.md"
add_section "setup-argocd" "Setup ArgoCD" "ARGOCD_SETUP.md"
add_section "setup-gitops" "Setup GitOps" "GITOPS_SETUP.md"
add_section "quick-start" "Quick Start" "DEVELOPER_QUICK_START.md"
add_section "actualizacion-chart" "Actualización Chart" "ACTUALIZACION_CHART_TRANSVERSAL.md"
add_section "seguridad" "Seguridad" "SECURITY_CRITICAL.md"
add_section "troubleshooting" "Como Iniciar" "COMO_INICIAR.md"
add_section "produccion" "Checklist Producción" "PRODUCTION_CHECKLIST.md"

# Cerrar HTML
cat >> "$OUTPUT" << 'EOF'
    </div>

    <div class="footer">
        <p><strong>Backstage GitOps Platform</strong></p>
        <p>Documentación generada automáticamente - Diciembre 2025</p>
        <p>Estado: ✅ Implementación Completa y Funcional</p>
    </div>

    <script>
        // Inicializar Mermaid
        mermaid.initialize({ startOnLoad: true, theme: 'default' });
        
        // Smooth scroll para navegación
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });
    </script>
</body>
</html>
EOF

echo "✅ Documentación generada en: $OUTPUT"
echo "📂 Abre el archivo en tu navegador para ver la documentación completa"
echo ""
echo "Para abrir:"
echo "  open $OUTPUT"
