# Cómo Iniciar Backstage

## 🚀 Inicio Rápido

```bash
# Opción 1: Usar el script helper (recomendado)
./start-with-env.sh

# Opción 2: Inicio normal
yarn start
```

Luego abre: http://localhost:3000

## ✅ Verificación de Estado

### 1. Verificar que el Backend está corriendo

```bash
# Debe responder con JSON
curl http://localhost:7007/api/catalog/entities | head -20
```

### 2. Verificar que el Frontend está corriendo

```bash
# Debe responder con HTML
curl http://localhost:3000 | head -20
```

### 3. Verificar procesos

```bash
# Debe mostrar procesos de backstage
ps aux | grep backstage | grep -v grep
```

## 🔧 Si Backstage No Inicia

### Problema: "TypeError: Failed to fetch"

**Causa**: El backend no está corriendo o no responde.

**Solución**:

```bash
# 1. Matar procesos existentes
pkill -f backstage-cli

# 2. Verificar que los puertos están libres
lsof -i :3000  # Frontend
lsof -i :7007  # Backend

# 3. Si hay procesos, matarlos
kill -9 <PID>

# 4. Reiniciar
./start-with-env.sh
```

### Problema: "Port already in use"

**Solución**:

```bash
# Encontrar qué proceso usa el puerto
lsof -i :3000  # o :7007

# Matar el proceso
kill -9 <PID>

# Reiniciar
yarn start
```

### Problema: "Cannot connect to PostgreSQL"

**Solución**:

```bash
# 1. Verificar que PostgreSQL está corriendo
psql -h localhost -U postgres -d postgres

# 2. Si no está corriendo, iniciarlo
brew services start postgresql@14

# 3. Verificar credenciales en .env
cat .env | grep POSTGRES

# 4. Reiniciar Backstage
./restart-backstage.sh
```

### Problema: "GitHub token error"

**Solución**:

```bash
# 1. Verificar token en .env
cat .env | grep GITHUB_TOKEN

# 2. Probar token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# 3. Si falla, generar nuevo token en:
# https://github.com/settings/tokens

# 4. Actualizar .env y reiniciar
```

## 📋 Checklist Pre-Inicio

Antes de iniciar Backstage, verifica:

- [ ] PostgreSQL está corriendo
- [ ] `.env` tiene todas las variables necesarias
- [ ] No hay procesos de Backstage corriendo
- [ ] Puertos 3000 y 7007 están libres
- [ ] `node_modules` está instalado (`yarn install`)

## 🔍 Logs y Debugging

### Ver logs en tiempo real

```bash
# Los logs aparecen en la terminal donde ejecutaste yarn start
# Busca errores relacionados con:
# - PostgreSQL connection
# - GitHub token
# - ArgoCD configuration
# - Plugin loading
```

### Logs importantes a revisar

```bash
# Backend initialization
[backend] Loaded default config from app-config.yaml

# Database connection
[backend] Connected to database

# Plugins loading
[backend] Loaded plugin: catalog
[backend] Loaded plugin: scaffolder
[backend] Loaded plugin: kubernetes

# Server ready
[backend] Listening on :7007
[frontend] webpack compiled successfully
```

## 🎯 Verificación Post-Inicio

Una vez que Backstage esté corriendo:

### 1. Verificar Frontend

```bash
# Abrir en navegador
open http://localhost:3000

# Debe mostrar:
# - Página de inicio de Backstage
# - Menú lateral con: Home, Catalog, APIs, Docs, Create
# - Sin errores en consola del navegador
```

### 2. Verificar Backend

```bash
# Probar API de catálogo
curl http://localhost:7007/api/catalog/entities

# Debe retornar JSON con entidades
```

### 3. Verificar Catálogo

```bash
# En Backstage UI:
# 1. Click en "Catalog"
# 2. Debe mostrar componentes de ejemplo
# 3. Click en un componente
# 4. Debe mostrar detalles
```

### 4. Verificar Template

```bash
# En Backstage UI:
# 1. Click en "Create"
# 2. Debe mostrar "ArgoCD - Aplicación Hola Mundo"
# 3. Click en el template
# 4. Debe mostrar formulario
```

## 🔄 Reinicio Completo

Si nada funciona, reinicio completo:

```bash
# 1. Matar todos los procesos
pkill -f backstage
pkill -f node

# 2. Limpiar caché
yarn clean

# 3. Reinstalar dependencias
rm -rf node_modules
yarn install

# 4. Verificar PostgreSQL
psql -h localhost -U postgres -d postgres

# 5. Verificar .env
cat .env

# 6. Iniciar
./start-with-env.sh
```

## 📞 Soporte

Si sigues teniendo problemas:

1. Revisa `RESUMEN_FINAL.md` para estado del proyecto
2. Revisa `ARGOCD_PLUGIN_NOTE.md` para problema conocido
3. Revisa `SECURITY_CRITICAL.md` para temas de tokens
4. Revisa logs en la terminal
5. Busca errores en consola del navegador (F12)

## 🎓 Recursos Adicionales

- `README.md` - Documentación principal
- `DEVELOPER_QUICK_START.md` - Guía para desarrolladores
- `QUICK_REFERENCE.md` - Referencia rápida de comandos
- `PRODUCTION_CHECKLIST.md` - Lista para producción

---

**¡Listo para empezar! 🚀**
