#!/bin/bash

# Configurar Node 22 en el PATH
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# Configurar NODE_OPTIONS para Node 20+
export NODE_OPTIONS="--no-node-snapshot"

echo "🚀 Iniciando Backstage..."
echo "Node version: $(node --version)"
echo "Yarn version: $(yarn --version)"
echo ""

# Verificar si PostgreSQL está corriendo
echo "📊 Verificando PostgreSQL..."
if brew services list | grep postgresql@15 | grep started > /dev/null; then
    echo "✅ PostgreSQL ya está corriendo"
else
    echo "⚠️  PostgreSQL no está corriendo. Iniciando..."
    brew services start postgresql@15
    echo "✅ PostgreSQL iniciado"
    sleep 3
fi

echo ""
echo "🔧 Iniciando Backstage en modo desarrollo..."
echo ""
echo "Frontend: http://localhost:3000"
echo "Backend: http://localhost:7007"
echo ""

# Iniciar Backstage
yarn start
