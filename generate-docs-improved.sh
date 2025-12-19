#!/bin/bash

# Script mejorado para generar documentación HTML con Markdown y Mermaid renderizados

OUTPUT="docs/documentacion-completa.html"

echo "🚀 Generando documentación HTML mejorada..."

mkdir -p docs

# Crear HTML con soporte completo de Markdown y Mermaid
cat > "$OUTPUT" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Backstage GitOps Platform - Documentación Completa</title>
    
    <!-- Mermaid para diagramas -->
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
    
    <!-- Marked para renderizar Markdown -->
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    
    <!-- Highlight.js para syntax highlighting -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --primary: #4A90E2;
            --secondary: #FF6B35;
            --success: #28A745;
            --warning: #FFC107;
            --danger: #E74C3C;
            --dark: #2C3E50;
            --light: #ECF0F1;
            --code-bg: #282C34;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            background: #f5f7fa;
        }
        
        .header {
            background: linear-gradient(135deg, var(--primary) 0%, #357ABD 100%);
            color: white;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        .header h1 { font-size: 2.5rem; margin-bottom: 0.5rem; }
        .header p { font-size: 1.2rem; opacity: 0.9; }
        
        .nav {
            background: white;
            position: sticky;
            top: 100px;
            z-index: 999;
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
            overflow-x: auto;
        }
        
        .nav a {
            color: var(--dark);
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 5px;
            transition: all 0.3s;
            white-space: nowrap;
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
        
        .section h1 {
            color: var(--primary);
            font-size: 2.5rem;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 3px solid var(--primary);
        }
        
        .section h2 {
            color: var(--secondary);
            font-size: 2rem;
            margin: 2rem 0 1rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--secondary);
        }
        
        .section h3 {
            color: var(--dark);
            font-size: 1.5rem;
            margin: 1.5rem 0 1rem 0;
        }
        
        .section h4 {
            color: #555;
            font-size: 1.2rem;
            margin: 1rem 0 0.5rem 0;
        }
        
        .section p {
            margin: 1rem 0;
            line-height: 1.8;
        }
        
        .section ul, .section ol {
            margin: 1rem 0 1rem 2rem;
            line-height: 1.8;
        }
        
        .section li {
            margin: 0.5rem 0;
        }
        
        .section pre {
            background: var(--code-bg);
            color: #ABB2BF;
            padding: 1.5rem;
            border-radius: 8px;
            overflow-x: auto;
            margin: 1rem 0;
            border-left: 4px solid var(--primary);
        }
        
        .section code {
            background: #f4f4f4;
            color: #e83e8c;
            padding: 0.2rem 0.4rem;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        
        .section pre code {
            background: none;
            color: inherit;
            padding: 0;
        }
        
        .section table {
            width: 100%;
            border-collapse: collapse;
            margin: 1.5rem 0;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .section th {
            background: var(--primary);
            color: white;
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }
        
        .section td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid #ddd;
        }
        
        .section tr:hover {
            background: #f5f5f5;
        }
        
        .section blockquote {
            border-left: 4px solid var(--primary);
            padding-left: 1rem;
            margin: 1rem 0;
            color: #666;
            font-style: italic;
        }
        
        .section img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 1rem 0;
        }
        
        .mermaid {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin: 2rem 0;
            border: 1px solid #e0e0e0;
        }
        
        .alert {
            padding: 1rem;
            border-radius: 8px;
            margin: 1rem 0;
            border-left: 4px solid;
        }
        
        .alert-success {
            background: #d4edda;
            border-color: var(--success);
            color: #155724;
        }
        
        .alert-warning {
            background: #fff3cd;
            border-color: var(--warning);
            color: #856404;
        }
        
        .alert-danger {
            background: #f8d7da;
            border-color: var(--danger);
            color: #721c24;
        }
        
        .alert-info {
            background: #d1ecf1;
            border-color: var(--primary);
            color: #0c5460;
        }
        
        .footer {
            background: var(--dark);
            color: white;
            text-align: center;
            padding: 2rem;
            margin-top: 3rem;
        }
        
        .toc {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
            margin: 1rem 0;
            border-left: 4px solid var(--primary);
        }
        
        @media (max-width: 768px) {
            .header h1 { font-size: 1.8rem; }
            .nav-content { flex-direction: column; }
            .section { padding: 1rem; }
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
            <a href="#setup-argocd">⚙️ ArgoCD</a>
            <a href="#setup-gitops">🔄 GitOps</a>
            <a href="#quick-start">🚀 Quick Start</a>
            <a href="#chart">📦 Chart</a>
            <a href="#seguridad">🔐 Seguridad</a>
            <a href="#inicio">🐛 Inicio</a>
            <a href="#produccion">✅ Producción</a>
        </div>
    </nav>

    <div class="container">
HTMLEOF

# Función para agregar sección con Markdown renderizado
add_section() {
    local id=$1
    local title=$2
    local file=$3
    
    if [ -f "$file" ]; then
        echo "  📄 Agregando: $title"
        echo "<section id=\"$id\" class=\"section\">" >> "$OUTPUT"
        echo "<div class=\"markdown-content\">" >> "$OUTPUT"
        
        # Leer el contenido del archivo y escapar para JavaScript
        content=$(cat "$file" | sed 's/\\/\\\\/g' | sed "s/'/\\\\'/g" | sed ':a;N;$!ba;s/\n/\\n/g')
        
        # Agregar script para renderizar Markdown
        cat >> "$OUTPUT" << SCRIPTEOF
<script>
(function() {
    const markdown = '$content';
    const html = marked.parse(markdown);
    document.currentScript.parentElement.innerHTML = html;
})();
</script>
SCRIPTEOF
        
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
add_section "chart" "Actualización Chart" "ACTUALIZACION_CHART_TRANSVERSAL.md"
add_section "seguridad" "Seguridad" "SECURITY_CRITICAL.md"
add_section "inicio" "Como Iniciar" "COMO_INICIAR.md"
add_section "produccion" "Checklist Producción" "PRODUCTION_CHECKLIST.md"

# Cerrar HTML
cat >> "$OUTPUT" << 'HTMLEOF'
    </div>

    <div class="footer">
        <p><strong>Backstage GitOps Platform v1.0.0</strong></p>
        <p>Documentación generada automáticamente - Diciembre 2025</p>
        <p>Estado: ✅ Implementación Completa y Funcional</p>
    </div>

    <script>
        // Configurar Marked
        marked.setOptions({
            highlight: function(code, lang) {
                if (lang && hljs.getLanguage(lang)) {
                    return hljs.highlight(code, { language: lang }).value;
                }
                return hljs.highlightAuto(code).value;
            },
            breaks: true,
            gfm: true
        });
        
        // Inicializar Mermaid
        mermaid.initialize({ 
            startOnLoad: true, 
            theme: 'default',
            securityLevel: 'loose'
        });
        
        // Smooth scroll
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            });
        });
        
        // Highlight code blocks después de renderizar
        setTimeout(() => {
            document.querySelectorAll('pre code').forEach((block) => {
                hljs.highlightElement(block);
            });
        }, 1000);
    </script>
</body>
</html>
HTMLEOF

echo "✅ Documentación mejorada generada en: $OUTPUT"
echo "📂 Abre el archivo en tu navegador:"
echo "   open $OUTPUT"
