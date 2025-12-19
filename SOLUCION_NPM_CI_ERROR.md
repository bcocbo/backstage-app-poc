# 🔧 Solución: npm ci Error

## ❌ Error

```
npm ci --only=production did not complete successfully: exit code: 1
```

## 🔍 Causa

`npm ci` requiere que exista `package-lock.json`, pero el template no lo incluye.

## ✅ Solución Rápida

### Opción 1: Agregar package-lock.json al Repo

```bash
# 1. Clona tu repo
git clone https://github.com/bcocbo/test-app03.git
cd test-app03

# 2. Genera package-lock.json
npm install

# 3. Commit y push
git add package-lock.json
git commit -m "chore: Add package-lock.json"
git push origin main
```

### Opción 2: Modificar Dockerfile para Usar npm install

Si no quieres agregar `package-lock.json`, modifica el `Dockerfile`:

```dockerfile
# Cambiar esta línea:
RUN npm ci --only=production

# Por esta:
RUN npm install --only=production
```

**Pasos**:
```bash
# 1. Clona tu repo
git clone https://github.com/bcocbo/test-app03.git
cd test-app03

# 2. Edita Dockerfile
# Busca la línea con "npm ci" y cámbiala por "npm install"

# 3. Commit y push
git add Dockerfile
git commit -m "fix: Use npm install instead of npm ci"
git push origin main
```

## 🎯 Solución Permanente (Para Futuras Apps)

El Dockerfile del template ya está actualizado para manejar ambos casos:

```dockerfile
# Usar npm ci si existe package-lock.json, sino npm install
RUN if [ -f package-lock.json ]; then \
      npm ci --only=production; \
    else \
      npm install --only=production; \
    fi
```

**Para apps nuevas**: El problema ya está resuelto en el template.

**Para apps existentes**: Usa Opción 1 o 2 arriba.

## 📋 Diferencias entre npm ci y npm install

| Comando | Requiere | Velocidad | Uso |
|---------|----------|-----------|-----|
| `npm ci` | `package-lock.json` | ⚡ Más rápido | CI/CD, producción |
| `npm install` | Solo `package.json` | 🐢 Más lento | Desarrollo |

## 🧪 Probar Localmente

Antes de hacer push:

```bash
# Opción A: Con package-lock.json
npm install
docker build -t test:local .

# Opción B: Sin package-lock.json (modificar Dockerfile primero)
docker build -t test:local .

# Ejecutar
docker run -p 3000:3000 test:local

# Probar
curl http://localhost:3000
curl http://localhost:3000/health
```

## 🔍 Verificar el Fix

```bash
# Ver workflows
gh run list --repo bcocbo/test-app03

# Ver logs del último run
gh run view --repo bcocbo/test-app03 --log

# Verificar que el build pasa
gh run view --repo bcocbo/test-app03 --log | grep -A 5 "Build and push"
```

## 💡 Recomendación

**Para tu app actual (test-app03)**:
- Usa **Opción 1** (agregar package-lock.json)
- Es más rápido y es la mejor práctica

**Para futuras apps**:
- El template ya está corregido
- Funcionará automáticamente con o sin package-lock.json

---

**Última actualización**: 6 de Diciembre, 2025  
**Estado**: ✅ Dockerfile actualizado para manejar ambos casos
