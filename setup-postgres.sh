#!/bin/bash

echo "🔍 Verificando PostgreSQL..."

# Verificar si PostgreSQL está instalado
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL no está instalado"
    echo ""
    echo "Para instalar PostgreSQL en macOS:"
    echo "  brew install postgresql@14"
    echo "  brew services start postgresql@14"
    echo ""
    echo "O usa la app Postgres.app: https://postgresapp.com/"
    echo ""
    exit 1
fi

echo "✅ PostgreSQL encontrado"
echo ""

# Verificar si el servicio está corriendo
if ! pg_isready &> /dev/null; then
    echo "⚠️  PostgreSQL no está corriendo"
    echo ""
    echo "Para iniciar PostgreSQL:"
    echo "  brew services start postgresql@14"
    echo "  # O si usas Postgres.app, inícialo desde la aplicación"
    echo ""
    exit 1
fi

echo "✅ PostgreSQL está corriendo"
echo ""

# Obtener el usuario actual
CURRENT_USER=$(whoami)
echo "👤 Usuario actual: $CURRENT_USER"
echo ""

# Crear el rol postgres si no existe
echo "🔧 Creando rol 'postgres'..."
psql -d postgres -c "CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres' SUPERUSER;" 2>/dev/null || echo "   (El rol ya existe o no se pudo crear)"

# Crear el rol con el usuario actual si no existe
echo "🔧 Creando rol '$CURRENT_USER'..."
psql -d postgres -c "CREATE ROLE $CURRENT_USER WITH LOGIN SUPERUSER;" 2>/dev/null || echo "   (El rol ya existe)"

# Crear las bases de datos necesarias
echo ""
echo "📦 Creando bases de datos de Backstage..."

databases=(
    "backstage_plugin_app"
    "backstage_plugin_auth"
    "backstage_plugin_catalog"
    "backstage_plugin_scaffolder"
    "backstage_plugin_search"
    "backstage_plugin_permission"
    "backstage_plugin_kubernetes"
)

for db in "${databases[@]}"; do
    echo "   Creando $db..."
    createdb -U postgres "$db" 2>/dev/null || echo "   (Ya existe)"
done

echo ""
echo "✅ Configuración de PostgreSQL completada!"
echo ""
echo "📝 Ahora puedes actualizar app-config.yaml para usar PostgreSQL:"
echo ""
echo "database:"
echo "  client: pg"
echo "  connection:"
echo "    host: localhost"
echo "    port: 5432"
echo "    user: postgres"
echo "    password: postgres"
echo ""
