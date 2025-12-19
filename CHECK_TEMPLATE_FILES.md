# 🔍 Verificar Archivos del Template

## Problema

El build de Docker falla con:
```
npm ci --only=production did not complete successfully
```

Esto significa que `package.json` no existe o está vacío en el repositorio generado.

## Diagnóstico

### 1. Verificar qué archivos se generaron

Ve a tu repositorio en GitHub y verifica qué archivos existen:

```
https://github.com/bcocbo/test-app03
```

**Deberías ver**:
- ✅ `Dockerfile`
- ✅ `.github/workflows/ci.yaml`
- ✅ `catalog-info.yaml`
- ✅ `README.md`
- ✅ **`package.json`** ← ¿Existe?
- ✅ **`index.js`** ← ¿Existe?
- ✅ **`healthcheck.js`** ← ¿Existe?

### 2. Verificar contenido de package.json

Si `package.json` existe, ábrelo y verifica:

**❌ MAL** (vacío o con condicionales):
```json
{% if values.language == 'nodejs' %}
{
  "name": "test-app03"
}
{% endif %}
```

**✅ BIEN** (JSON válido):
```json
{
  "name": "test-app03",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

### 3. Verificar parámetros usados al crear la app

Cuando creaste la app en Backstage, ¿qué seleccionaste?

- **Tipo de Aplicación**: ¿Custom o Prebuilt?
- **Lenguaje**: ¿nodejs, python, java, etc.?

## Soluciones

### Solución A: Los archivos no se generaron

Si `package.json`, `index.js` y `healthcheck.js` **NO existen** en tu repo:

**Causa**: El template no los incluyó

**Fix**:
```bash
# 1. Clona tu repo
git clone https://github.com/bcocbo/test-app03.git
cd test-app03

# 2. Crea package.json
cat > package.json << 'EOF'
{
  "name": "test-app03",
  "version": "1.0.0",
  "description": "Test application",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# 3. Crea index.js
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

# 4. Crea healthcheck.js
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

# 5. Push
git add .
git commit -m "feat: Add Node.js application files"
git push origin main
```

### Solución B: Los archivos existen pero están vacíos o con condicionales

Si los archivos existen pero tienen contenido como `{% if ... %}`:

**Causa**: Los condicionales de template no se procesaron

**Fix**: Necesitas actualizar el template en Backstage y recrear la app

1. Los archivos del template ya están corregidos (sin condicionales al inicio)
2. Elimina el repo actual: `test-app03`
3. Vuelve a crear la app en Backstage
4. Verifica que ahora los archivos se generen correctamente

### Solución C: Usar imagen preconstruida temporalmente

Si quieres que funcione **ahora mismo** sin código:

1. Ve a Backstage → Create
2. Selecciona **"Imagen Preconstruida"** en lugar de "Custom"
3. Usa imagen: `nginxdemos/hello`
4. Tag: `latest`
5. Esto desplegará nginx sin necesidad de build

## Verificar el Fix

Después de aplicar cualquier solución:

```bash
# Ver el workflow
gh run list --repo bcocbo/test-app03

# Ver logs
gh run view --repo bcocbo/test-app03 --log

# Buscar el error específico
gh run view --repo bcocbo/test-app03 --log | grep -A 10 "npm ci"
```

## Prevenir el Problema

Para futuras aplicaciones:

1. **Verifica el template** antes de crear apps:
   ```bash
   ls -la examples/argocd-template/content/
   ```
   
   Deberías ver:
   - `package.json` (sin `{% if %}` al inicio)
   - `index.js` (sin `{% if %}` al inicio)
   - `healthcheck.js` (sin `{% if %}` al inicio)

2. **Prueba el template localmente**:
   ```bash
   # Copia los archivos a un directorio temporal
   cp -r examples/argocd-template/content /tmp/test-template
   cd /tmp/test-template
   
   # Verifica que package.json es válido
   cat package.json | jq .
   
   # Intenta build
   docker build -t test:local .
   ```

3. **Usa el tipo correcto**:
   - **Custom + nodejs**: Para aplicaciones Node.js con código
   - **Custom + python**: Para aplicaciones Python con código
   - **Prebuilt**: Para imágenes ya construidas (nginx, redis, etc.)

## Resumen

El error ocurre porque:
1. ❌ `package.json` no existe en el repo
2. ❌ O `package.json` está vacío/con condicionales
3. ❌ O seleccionaste "Prebuilt" pero el Dockerfile espera código

**Solución rápida**: Usa Solución A (agregar archivos manualmente)

**Solución permanente**: Corregir template y recrear app

---

**Última actualización**: 6 de Diciembre, 2025
