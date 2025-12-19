# 🔧 Fix: Docker Build Error

## ❌ Error

```
ERROR: failed to build: failed to solve: 
process "/bin/sh -c npm ci --only=production" did not complete successfully: exit code: 1
```

## 🔍 Causa

El Dockerfile intenta ejecutar `npm ci` pero **no existe `package.json`** en el repositorio generado por el template.

El template original solo incluía:
- ✅ `Dockerfile`
- ✅ `.github/workflows/ci.yaml`
- ✅ `catalog-info.yaml`
- ❌ **Faltaba**: Código fuente de la aplicación

## ✅ Solución Aplicada

He agregado archivos de código fuente para cada lenguaje:

### Node.js
- ✅ `package.json` - Dependencias (Express)
- ✅ `index.js` - Aplicación Express simple
- ✅ `healthcheck.js` - Health check para Docker

### Python
- ✅ `requirements.txt` - Dependencias (Flask)
- ✅ `app.py` - Aplicación Flask simple
- ✅ `healthcheck.py` - Health check para Docker

### Otros Lenguajes
Los archivos para Java, Go y .NET se agregarán según necesidad.

## 🚀 Próximos Pasos

### Si Ya Creaste una Aplicación

Tu aplicación ya fue creada pero le faltan los archivos de código. Tienes 2 opciones:

#### Opción 1: Agregar Archivos Manualmente (Rápido)

1. **Clona tu repositorio**:
   ```bash
   git clone https://github.com/bcocbo/TU-APP.git
   cd TU-APP
   ```

2. **Crea los archivos necesarios**:

   **Para Node.js**:
   ```bash
   # package.json
   cat > package.json << 'EOF'
   {
     "name": "tu-app",
     "version": "1.0.0",
     "description": "Mi aplicación",
     "main": "index.js",
     "scripts": {
       "start": "node index.js"
     },
     "dependencies": {
       "express": "^4.18.2"
     }
   }
   EOF

   # index.js
   cat > index.js << 'EOF'
   const express = require('express');
   const app = express();
   const PORT = process.env.PORT || 3000;

   app.use(express.json());

   app.get('/', (req, res) => {
     res.json({
       message: 'Hello World!',
       timestamp: new Date().toISOString()
     });
   });

   app.get('/health', (req, res) => {
     res.json({ status: 'healthy' });
   });

   app.listen(PORT, '0.0.0.0', () => {
     console.log(`Server running on port ${PORT}`);
   });
   EOF

   # healthcheck.js
   cat > healthcheck.js << 'EOF'
   const http = require('http');
   const options = {
     host: 'localhost',
     port: process.env.PORT || 3000,
     path: '/health',
     timeout: 2000
   };
   const request = http.request(options, (res) => {
     process.exit(res.statusCode === 200 ? 0 : 1);
   });
   request.on('error', () => process.exit(1));
   request.end();
   EOF
   ```

   **Para Python**:
   ```bash
   # requirements.txt
   cat > requirements.txt << 'EOF'
   flask==3.0.0
   gunicorn==21.2.0
   EOF

   # app.py
   cat > app.py << 'EOF'
   from flask import Flask, jsonify
   from datetime import datetime
   import os

   app = Flask(__name__)

   @app.route('/')
   def hello():
       return jsonify({
           'message': 'Hello World!',
           'timestamp': datetime.now().isoformat()
       })

   @app.route('/health')
   def health():
       return jsonify({'status': 'healthy'})

   if __name__ == '__main__':
       port = int(os.environ.get('PORT', 8000))
       app.run(host='0.0.0.0', port=port)
   EOF

   # healthcheck.py
   cat > healthcheck.py << 'EOF'
   import http.client
   import sys
   import os

   try:
       port = int(os.environ.get('PORT', 8000))
       conn = http.client.HTTPConnection('localhost', port, timeout=2)
       conn.request('GET', '/health')
       response = conn.getresponse()
       sys.exit(0 if response.status == 200 else 1)
   except:
       sys.exit(1)
   EOF
   ```

3. **Commit y push**:
   ```bash
   git add .
   git commit -m "feat: Add application source code"
   git push origin main
   ```

4. **El workflow se ejecutará automáticamente** y ahora debería funcionar.

#### Opción 2: Recrear la Aplicación (Recomendado)

1. **Elimina el repositorio actual** (si está vacío o no tiene código importante)
2. **Vuelve a Backstage** y crea la aplicación de nuevo
3. **Ahora incluirá todos los archivos** necesarios

### Si Vas a Crear una Nueva Aplicación

Los archivos ya están agregados al template. Simplemente:

1. Ve a Backstage → **Create**
2. Selecciona **ArgoCD - Aplicación Hola Mundo**
3. Completa el formulario
4. La aplicación se creará con **todo el código necesario**

## 📋 Archivos Incluidos Ahora

### Para Aplicaciones Node.js

```
tu-app/
├── .github/
│   └── workflows/
│       └── ci.yaml          # CI/CD pipeline
├── package.json             # ✅ NUEVO
├── index.js                 # ✅ NUEVO
├── healthcheck.js           # ✅ NUEVO
├── Dockerfile
├── catalog-info.yaml
└── README.md
```

### Para Aplicaciones Python

```
tu-app/
├── .github/
│   └── workflows/
│       └── ci.yaml          # CI/CD pipeline
├── requirements.txt         # ✅ NUEVO
├── app.py                   # ✅ NUEVO
├── healthcheck.py           # ✅ NUEVO
├── Dockerfile
├── catalog-info.yaml
└── README.md
```

## 🧪 Probar Localmente

Antes de hacer push, puedes probar el build localmente:

### Node.js
```bash
# Instalar dependencias
npm install

# Ejecutar
npm start

# Probar
curl http://localhost:3000
curl http://localhost:3000/health

# Build Docker
docker build -t mi-app:test .
docker run -p 3000:3000 mi-app:test
```

### Python
```bash
# Instalar dependencias
pip install -r requirements.txt

# Ejecutar
python app.py

# Probar
curl http://localhost:8000
curl http://localhost:8000/health

# Build Docker
docker build -t mi-app:test .
docker run -p 8000:8000 mi-app:test
```

## 🔍 Verificar el Build en GitHub Actions

Después de hacer push:

```bash
# Ver workflows
gh run list --repo bcocbo/TU-APP

# Ver logs del último run
gh run view --repo bcocbo/TU-APP --log

# Ver solo el step de build
gh run view --repo bcocbo/TU-APP --log | grep -A 20 "Build and push"
```

## 💡 Personalizar la Aplicación

Los archivos generados son **ejemplos básicos**. Puedes:

1. **Agregar más rutas**:
   ```javascript
   app.get('/api/users', (req, res) => {
     res.json({ users: [] });
   });
   ```

2. **Agregar dependencias**:
   ```bash
   npm install axios dotenv
   ```

3. **Agregar variables de entorno**:
   ```javascript
   const DB_HOST = process.env.DB_HOST || 'localhost';
   ```

4. **Agregar tests**:
   ```bash
   npm install --save-dev jest
   ```

## 🐛 Troubleshooting

### Error: "Cannot find module 'express'"

**Causa**: Dependencias no instaladas

**Solución**:
```bash
npm install
```

### Error: "EADDRINUSE: address already in use"

**Causa**: Puerto ya en uso

**Solución**:
```bash
# Cambiar puerto
PORT=3001 npm start

# O matar el proceso
lsof -ti:3000 | xargs kill
```

### Error: "Docker build still failing"

**Causa**: Cache de Docker

**Solución**:
```bash
# Build sin cache
docker build --no-cache -t mi-app:test .
```

## 📊 Checklist

- [ ] Archivos de código agregados al repositorio
- [ ] `package.json` o `requirements.txt` existe
- [ ] Archivo principal (`index.js` o `app.py`) existe
- [ ] `healthcheck.js` o `healthcheck.py` existe
- [ ] Build local funciona
- [ ] Push a GitHub
- [ ] Workflow se ejecuta sin errores
- [ ] Imagen se sube a ECR
- [ ] PR se crea en GitOps repo

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Archivos de código agregados al template
