#!/bin/bash

# Cargar variables de entorno desde .env
set -a
source .env
set +a

echo "🔍 Verificando configuración..."
echo ""

# Verificar que el token esté cargado
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ ERROR: GITHUB_TOKEN no está configurado"
    echo "Por favor verifica el archivo .env"
    exit 1
else
    echo "✅ GITHUB_TOKEN configurado: ${GITHUB_TOKEN:0:10}..."
fi

echo "✅ POSTGRES_HOST: $POSTGRES_HOST"
echo "✅ POSTGRES_USER: $POSTGRES_USER"
echo ""

echo "🚀 Iniciando Backstage con variables de entorno..."
echo ""

# Iniciar Backstage
yarn start
