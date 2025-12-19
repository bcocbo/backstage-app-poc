#!/usr/bin/env python3
"""
Script para generar documentación HTML consolidada con Markdown y Mermaid renderizados
"""

import os
import json

# Archivos a incluir
DOCS = [
    ("readme", "📖 README", "README.md"),
    ("acceso", "📚 Acceso a Documentación", "ACCESO_DOCUMENTACION.md"),
    ("resumen", "📊 Resumen Final", "RESUMEN_FINAL.md"),
    ("arquitectura", "🏗️ Arquitectura", "ARQUITECTURA_DIAGRAMA.md"),
    ("setup-argocd", "⚙️ Setup ArgoCD", "ARGOCD_SETUP.md"),
    ("setup-gitops", "🔄 Setup GitOps", "GITOPS_SETUP.md"),
    ("quick-start", "🚀 Quick Start", "DEVELOPER_QUICK_START.md"),
    ("chart", "📦 Actualización Chart", "ACTUALIZACION_CHART_TRANSVERSAL.md"),
    ("plugin", "🔌 Agregar Plugin", "GUIA_AGREGAR_PLUGIN.md"),
    ("scaffolder", "📝 Crear Scaffolder", "GUIA_CREAR_SCAFFOLDER.md"),
    ("seguridad", "🔐 Seguridad", "SECURITY_CRITICAL.md"),
    ("inicio", "🐛 Como Iniciar", "COMO_INICIAR.md"),
    ("produccion", "✅ Producción", "PRODUCTION_CHECKLIST.md"),
]

HTML_TEMPLATE = '''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Backstage GitOps Platform - Documentación Completa</title>
    
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
    
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --primary: #4A90E2;
            --secondary: #FF6B35;
            --success: #28A745;
            --dark: #2C3E50;
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
        
        .section p {
            margin: 1rem 0;
            line-height: 1.8;
        }
        
        .section ul, .section ol {
            margin: 1rem 0 1rem 2rem;
            line-height: 1.8;
        }
        
        .section pre {
            background: var(--code-bg);
            color: #ABB2BF;
            padding: 1.5rem;
            border-radius: 8px;
            overflow-x: auto;
            margin: 1rem 0;
        }
        
        .section code {
            background: #f4f4f4;
            color: #e83e8c;
            padding: 0.2rem 0.4rem;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
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
        }
        
        .section th {
            background: var(--primary);
            color: white;
            padding: 1rem;
            text-align: left;
        }
        
        .section td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid #ddd;
        }
        
        .section tr:hover {
            background: #f5f5f5;
        }
        
        .mermaid {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin: 2rem 0;
            border: 1px solid #e0e0e0;
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
            {nav_links}
        </div>
    </nav>

    <div class="container">
        {sections}
    </div>

    <div class="footer">
        <p><strong>Backstage GitOps Platform v1.0.0</strong></p>
        <p>Documentación generada automáticamente - Diciembre 2025</p>
        <p>Estado: ✅ Implementación Completa y Funcional</p>
    </div>

    <script>
        marked.setOptions({{
            highlight: function(code, lang) {{
                if (lang && hljs.getLanguage(lang)) {{
                    return hljs.highlight(code, {{{{ language: lang }}}}).value;
                }}
                return hljs.highlightAuto(code).value;
            }},
            breaks: true,
            gfm: true
        }});
        
        mermaid.initialize({{{{ 
            startOnLoad: false, 
            theme: 'default',
            securityLevel: 'loose'
        }}}});
        
        // Smooth scroll para navegación
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {{
            anchor.addEventListener('click', function (e) {{
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {{
                    target.scrollIntoView({{{{ behavior: 'smooth', block: 'start' }}}});
                }}
            }});
        }});
        
        // Procesar después de que todo el contenido esté cargado
        setTimeout(() => {{
            // Highlight code blocks
            document.querySelectorAll('pre code:not(.language-mermaid)').forEach((block) => {{
                hljs.highlightElement(block);
            }});
            
            // Convertir bloques mermaid a divs
            document.querySelectorAll('pre code.language-mermaid').forEach((block) => {{
                const pre = block.parentElement;
                const mermaidDiv = document.createElement('div');
                mermaidDiv.className = 'mermaid';
                mermaidDiv.textContent = block.textContent;
                pre.parentElement.replaceChild(mermaidDiv, pre);
            }});
            
            // Renderizar diagramas mermaid
            mermaid.run({{{{ querySelector: '.mermaid' }}}});
        }}, 500);
    </script>
</body>
</html>
'''

def read_file(filepath):
    """Lee un archivo y retorna su contenido"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return f"# Archivo no encontrado: {filepath}"

def escape_for_js(text):
    """Escapa texto para JavaScript"""
    return json.dumps(text)

def generate_html():
    """Genera el HTML consolidado"""
    print("🚀 Generando documentación HTML...")
    
    # Crear directorio si no existe
    os.makedirs('docs', exist_ok=True)
    
    # Generar enlaces de navegación
    nav_links = []
    for doc_id, title, _ in DOCS:
        nav_links.append(f'<a href="#{doc_id}">{title}</a>')
    
    # Generar secciones
    sections = []
    for doc_id, title, filepath in DOCS:
        if os.path.exists(filepath):
            print(f"  📄 Agregando: {title}")
            content = read_file(filepath)
            content_json = escape_for_js(content)
            
            section = f'''
<section id="{doc_id}" class="section">
    <div class="markdown-content"></div>
    <script>
        (function() {{
            const markdown = {content_json};
            const html = marked.parse(markdown);
            document.currentScript.previousElementSibling.innerHTML = html;
        }})();
    </script>
</section>
'''
            sections.append(section)
    
    # Generar HTML final
    html = HTML_TEMPLATE.replace('{nav_links}', '\n            '.join(nav_links))
    html = html.replace('{sections}', '\n        '.join(sections))
    
    # Escribir archivo
    output_path = 'docs/documentacion-completa.html'
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"✅ Documentación generada en: {output_path}")
    print(f"📂 Abre el archivo en tu navegador:")
    print(f"   open {output_path}")

if __name__ == '__main__':
    generate_html()
