# 🔧 Fix: Template Genera Archivos del Lenguaje Incorrecto

## ❌ Problema

Cuando creas una app **Python**, el template genera archivos de **Node.js**:
- ❌ `package.json` (Node.js)
- ❌ `index.js` (Node.js)
- ❌ `healthcheck.js` (Node.js)

Y viceversa.

## 🔍 Causa

El template original usaba `fetch:template` con un solo directorio `content/` que contenía **todos** los archivos de todos los lenguajes. Backstage copiaba todo sin filtrar.

## ✅ Solución Aplicada

### Nueva Estructura

```
examples/argocd-template/
├── content/                    # Archivos comunes (todos los lenguajes)
│   ├── .github/
│   ├── Dockerfile
│   ├── catalog-info.yaml
│   ├── README.md
│   └── .gitignore
├── content-nodejs/             # Solo para Node.js
│   ├── package.json
│   ├── index.js
│   └── healthcheck.js
└── content-python/             # Solo para Python
    ├── requirements.txt
    ├── app.py
    └── healthcheck.py
```

### Cambios en template.yaml

Ahora usa **fetch condicional**:

```yaml
steps:
  # 1. Fetch archivos comunes
  - id: fetch-base
    action: fetch:template
    input:
      url: ./content
  
  # 2. Fetch archivos de Node.js (solo si language == nodejs)
  - id: fetch-nodejs
    if: ${{ parameters.language == 'nodejs' }}
    action: fetch:template
    input:
      url: ./content-nodejs
  
  # 3. Fetch archivos de Python (solo si language == python)
  - id: fetch-python
    if: ${{ parameters.language == 'python' }}
    action: fetch:template
    input:
      url: ./content-python
```

## 🎯 Resultado

Ahora cuando creas una app:

### App Node.js
Genera:
- ✅ `Dockerfile` (con build de Node.js)
- ✅ `package.json`
- ✅ `index.js`
- ✅ `healthcheck.js`
- ❌ NO genera archivos de Python

### App Python
Genera:
- ✅ `Dockerfile` (con build de Python)
- ✅ `requirements.txt`
- ✅ `app.py`
- ✅ `healthcheck.py`
- ❌ NO genera archivos de Node.js

## 🚀 Para Probar

### 1. Reiniciar Backstage

```bash
# Detener Backstage
pkill -f backstage

# Iniciar de nuevo
yarn start
```

O simplemente:
```bash
./restart-backstage.sh
```

### 2. Crear App de Prueba

1. Ve a Backstage → **Create**
2. Selecciona **ArgoCD - Aplicación Hola Mundo**
3. Completa:
   - Nombre: `test-python-app`
   - Tipo: **Custom**
   - Lenguaje: **Python**
4. Click **Create**

### 3. Verificar Archivos Generados

Ve al repo creado y verifica:

```bash
# Clonar
git clone https://github.com/bcocbo/test-python-app.git
cd test-python-app

# Listar archivos
ls -la

# Deberías ver:
# ✅ requirements.txt
# ✅ app.py
# ✅ healthcheck.py
# ❌ NO package.json
# ❌ NO index.js
```

## 📋 Checklist de Verificación

### Para App Node.js
- [ ] Existe `package.json`
- [ ] Existe `index.js`
- [ ] Existe `healthcheck.js`
- [ ] NO existe `requirements.txt`
- [ ] NO existe `app.py`
- [ ] Dockerfile usa `FROM node:20-alpine`

### Para App Python
- [ ] Existe `requirements.txt`
- [ ] Existe `app.py`
- [ ] Existe `healthcheck.py`
- [ ] NO existe `package.json`
- [ ] NO existe `index.js`
- [ ] Dockerfile usa `FROM python:3.11-slim`

## 🔄 Migrar Apps Existentes

Si ya creaste apps con archivos incorrectos:

### Opción 1: Limpiar Archivos Incorrectos

```bash
# Para app Python que tiene archivos de Node.js
git clone https://github.com/bcocbo/TU-APP.git
cd TU-APP

# Eliminar archivos de Node.js
rm package.json index.js healthcheck.js

# Commit
git add .
git commit -m "chore: Remove incorrect Node.js files"
git push origin main
```

### Opción 2: Recrear la App

1. Elimina el repositorio actual
2. Vuelve a crear la app en Backstage
3. Ahora generará los archivos correctos

## 💡 Agregar Más Lenguajes

Para agregar soporte para Java, Go, .NET, etc.:

1. **Crear directorio**:
   ```bash
   mkdir examples/argocd-template/content-java
   ```

2. **Agregar archivos**:
   ```bash
   # content-java/pom.xml
   # content-java/src/main/java/App.java
   # etc.
   ```

3. **Actualizar template.yaml**:
   ```yaml
   - id: fetch-java
     if: ${{ parameters.language == 'java' }}
     action: fetch:template
     input:
       url: ./content-java
   ```

## 🎉 Beneficios

- ✅ Apps generan solo los archivos necesarios
- ✅ No hay confusión entre lenguajes
- ✅ Builds más limpios
- ✅ Fácil agregar más lenguajes
- ✅ Mejor experiencia de desarrollador

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Template corregido con fetch condicional
