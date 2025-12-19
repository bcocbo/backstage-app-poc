# Solución Definitiva: Token de GitHub

## 🔍 Problema
El token de GitHub no está siendo reconocido por el scaffolder de Backstage.

## ✅ Solución Paso a Paso

### Paso 1: Detener Backstage Completamente
```bash
# Matar todos los procesos de Backstage
pkill -f "backstage"
pkill -f "node.*backend"
pkill -f "webpack"

# Verificar que no quede nada corriendo
ps aux | grep -E "backstage|webpack" | grep -v grep
```

### Paso 2: Verificar el Token
```bash
# Ver el token en .env
cat .env | grep GITHUB_TOKEN

# Debe mostrar:
# GITHUB_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE
```

### Paso 3: Iniciar con Variables de Entorno Explícitas

**Opción A: Usar el nuevo script (RECOMENDADO)**
```bash
./start-with-env.sh
```

Este script:
- Carga explícitamente las variables de `.env`
- Verifica que el token esté configurado
- Inicia Backstage con las variables cargadas

**Opción B: Exportar manualmente**
```bash
# Exportar el token explícitamente
export GITHUB_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres

# Verificar que se exportó
echo $GITHUB_TOKEN

# Iniciar Backstage
yarn start
```

### Paso 4: Verificar en los Logs

Cuando Backstage inicie, busca en los logs:
```
[1] info: Reading GitHub integration config
```

Si ves errores relacionados con GitHub, cópialos y avísame.

### Paso 5: Probar el Template

1. Ve a http://localhost:3000
2. Click en "Create..."
3. Selecciona "ArgoCD - Aplicación Hola Mundo"
4. Llena el formulario
5. Click "Create"

## 🔧 Configuración Actualizada

He actualizado `app-config.yaml` para incluir configuración explícita del token en el scaffolder:

```yaml
scaffolder:
  github:
    token: ${GITHUB_TOKEN}
    visibility: public
```

## 🐛 Si Aún No Funciona

### Verificar que el token sea válido
```bash
curl -H "Authorization: token ghp_YOUR_ACTUAL_TOKEN_HERE" \
     https://api.github.com/user
```

Debe devolver tu información de usuario, no un error 401.

### Verificar permisos del token

El token debe tener estos scopes en GitHub:
- ✅ `repo` (Full control of private repositories)
- ✅ `workflow` (Update GitHub Action workflows)
- ✅ `write:packages` (Upload packages to GitHub Package Registry)

Para verificar/crear un nuevo token:
1. Ve a https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Selecciona los scopes mencionados arriba
4. Copia el nuevo token
5. Actualiza `.env` con el nuevo token
6. Reinicia Backstage con `./start-with-env.sh`

### Limpiar y Reinstalar

Si nada funciona:
```bash
# Limpiar todo
yarn clean
rm -rf node_modules
rm -rf packages/*/node_modules

# Reinstalar
yarn install

# Iniciar con el script
./start-with-env.sh
```

## 📋 Checklist Final

- [ ] Backstage completamente detenido
- [ ] Token verificado en `.env`
- [ ] Token válido (probado con curl)
- [ ] Token tiene permisos correctos
- [ ] Backstage iniciado con `./start-with-env.sh`
- [ ] Logs no muestran errores de GitHub
- [ ] Template visible en la UI
- [ ] Formulario se puede llenar

## 🆘 Última Opción: Hardcodear el Token (Solo para Testing)

**⚠️ SOLO PARA PRUEBAS LOCALES - NUNCA EN PRODUCCIÓN**

Si nada más funciona, puedes hardcodear temporalmente el token en `app-config.yaml`:

```yaml
integrations:
  github:
    - host: github.com
      token: ghp_YOUR_ACTUAL_TOKEN_HERE  # TEMPORAL - Reemplazar con tu token!

scaffolder:
  github:
    token: ghp_YOUR_ACTUAL_TOKEN_HERE  # TEMPORAL - Reemplazar con tu token!
```

**IMPORTANTE**: Si haces esto:
1. Solo para probar que funciona
2. Revertir inmediatamente después
3. NUNCA commitear este archivo
4. Agregar `app-config.yaml` a `.gitignore` temporalmente

## 📞 Siguiente Paso

Después de seguir estos pasos, intenta crear la aplicación de nuevo y avísame:
- ¿Qué mensaje de error ves ahora?
- ¿Los logs muestran algo diferente?
- ¿El token se está cargando correctamente?
