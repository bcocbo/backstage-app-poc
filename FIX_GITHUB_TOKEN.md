# Solución: Token de GitHub no disponible

## 🔍 Problema
```
No token available for host: github.com, with owner bcocbo, and repo test-app
```

## ✅ Solución

### Opción 1: Reiniciar Backstage (Recomendado)

Backstage necesita reiniciarse para cargar las variables de entorno del archivo `.env`.

```bash
# Usar el script de reinicio
./restart-backstage.sh
```

O manualmente:

```bash
# 1. Detener Backstage
pkill -f "backstage-cli.*start"
pkill -f "node.*backend"

# 2. Esperar unos segundos
sleep 3

# 3. Iniciar de nuevo
yarn start
```

### Opción 2: Verificar que el token esté cargado

```bash
# Verificar que el token esté en .env
cat .env | grep GITHUB_TOKEN

# Debe mostrar:
# GITHUB_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE
```

### Opción 3: Configurar el token directamente (Temporal)

Si necesitas probar rápidamente sin reiniciar:

```bash
# Exportar el token en la terminal actual
export GITHUB_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE

# Luego iniciar Backstage desde esa misma terminal
yarn start
```

## 🧪 Verificar que funciona

Después de reiniciar, prueba el template:

1. Ve a http://localhost:3000
2. Click en "Create..."
3. Selecciona "ArgoCD - Aplicación Hola Mundo"
4. Llena el formulario:
   - Nombre: `test-app`
   - Entorno: `dev`
   - Owner: `bcocbo`
   - Repository: `test-app`
5. Click "Create"

Si todo está bien, deberías ver:
- ✅ "Publicar Repositorio de Aplicación" - Success
- ✅ "Crear PR en Repositorio GitOps" - Success
- ✅ "Registrar en el Catálogo" - Success

## 🔧 Verificación Adicional

### Verificar que el backend puede acceder al token:

```bash
# Desde la raíz del proyecto
node -e "require('dotenv').config(); console.log('Token:', process.env.GITHUB_TOKEN ? 'Configurado ✅' : 'NO configurado ❌')"
```

### Verificar logs del backend:

```bash
# Ver logs en tiempo real
tail -f backstage.log

# O si iniciaste con yarn start, los logs aparecerán en la terminal
```

Busca líneas como:
```
[1] info: Reading GitHub integration config from integrations.github
```

## 📋 Checklist de Verificación

- [ ] Token está en `.env`
- [ ] Token tiene formato `ghp_...`
- [ ] `app-config.yaml` tiene `token: ${GITHUB_TOKEN}`
- [ ] Backstage fue reiniciado después de agregar el token
- [ ] No hay errores en los logs del backend
- [ ] El template aparece en la UI
- [ ] Puedes llenar el formulario del template

## 🆘 Si aún no funciona

### 1. Verificar permisos del token

El token debe tener estos permisos en GitHub:
- ✅ `repo` (acceso completo a repositorios)
- ✅ `workflow` (para crear workflows)
- ✅ `write:packages` (si usas GitHub Packages)

Para verificar/actualizar:
1. Ve a https://github.com/settings/tokens
2. Click en el token
3. Verifica que tenga los permisos necesarios
4. Si no, genera un nuevo token con los permisos correctos

### 2. Verificar que el token no haya expirado

```bash
# Probar el token manualmente
curl -H "Authorization: token ghp_YOUR_ACTUAL_TOKEN_HERE" \
     https://api.github.com/user

# Debe devolver tu información de usuario, no un error 401
```

### 3. Limpiar caché de Backstage

```bash
# Limpiar node_modules y reinstalar
yarn clean
yarn install

# Limpiar build
rm -rf dist dist-types

# Reiniciar
yarn start
```

## 📚 Referencias

- [Backstage GitHub Integration](https://backstage.io/docs/integrations/github/locations)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Backstage Scaffolder](https://backstage.io/docs/features/software-templates/)
